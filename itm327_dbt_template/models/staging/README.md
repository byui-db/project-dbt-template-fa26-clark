# Staging Layer — The T in EtLT

## Why Staging Is Not Just `SELECT *`

Your Airflow DAGs handle the **Extract** and **Load** — they pull data from APIs and drop it into Snowflake's RAW schema as-is. That's their only job. RAW is a landing zone, not a trusted data source.

The **Transform** step starts here, in staging.

Every model downstream — your fact tables, dimension tables, and marts — inherits whatever is in staging. If a `NULL` slips through, it silently poisons an aggregation. If a symbol comes in as `aapl` instead of `AAPL`, your JOIN silently drops rows. If Airflow loads a duplicate record, your fact table grain is broken before you even write a single line of warehouse SQL.

Staging's job is to make a **promise** to every downstream model:

> "Every row that comes out of me has correct types, clean strings, no nulls where nulls are not allowed, and no duplicate natural keys."

Downstream models don't defensively re-clean data. They trust the staging contract.

---

## The Four Cleaning Patterns

### 1. Type Casting — `::` vs `TRY_CAST`

Airflow loads JSON and CSV data. Snowflake infers types, but inference can be wrong or inconsistent across loads. Always cast explicitly.

#### When to Use `::`  (Compile-Time Safe Casts)

Use `::` syntax for conversions that **always work** (no risk of invalid data):

```sql
-- NUMBER → VARCHAR (always safe)
id::VARCHAR AS id,

-- TIMESTAMP → DATE (always safe)
datetime::DATE AS date,

-- FLOAT → NUMBER (always safe, may round)
temperature::NUMBER(38,0) AS temperature,

-- VARCHAR → VARCHAR (safe, but explicit about intent)
headline::VARCHAR AS headline
```

**Why `::` syntax?** These conversions cannot fail at runtime — Snowflake guarantees they work. Using `TRY_CAST` for these will cause a **compile error** like:
```
Function TRY_CAST cannot be used with arguments of types NUMBER(38,0) and VARCHAR
```

#### When to Use `TRY_CAST` (Runtime Conversions That Might Fail)

Use `TRY_CAST` only when the **input might be invalid** and you want `NULL` instead of an error:

```sql
-- VARCHAR → NUMBER (might contain 'abc' or invalid text)
TRY_CAST(price_str AS FLOAT) AS price,

-- VARCHAR → DATE (might be malformed like '2026-13-45')
TRY_CAST(date_str AS DATE) AS parsed_date
```

**Why `TRY_CAST`?** When casting text to numbers or dates, the source data might be corrupt. `TRY_CAST` returns `NULL` for bad values instead of crashing the pipeline.

#### Applied to Your Raw Tables

**For stocks, news, and weather:** Airflow loads these with known types (TIMESTAMP, FLOAT, NUMBER, VARCHAR). Use `::` syntax:

```sql
-- Raw stocks
datetime::TIMESTAMP AS datetime,
symbol::VARCHAR AS symbol,
open::FLOAT AS open,
close::FLOAT AS close,
volume::NUMBER(38,0) AS volume

-- Raw news
id::VARCHAR AS id,
headline::VARCHAR AS headline,
datetime::TIMESTAMP AS datetime

-- Raw weather
city::VARCHAR AS city,
datetime::TIMESTAMP AS datetime,
temperature::FLOAT AS temperature
```

**Why it matters:** A `CLOSE` column stored as `VARCHAR` will silently return wrong results when you calculate `AVG(CLOSE)` in a fact table. Snowflake will cast on the fly sometimes, fail silently other times.

---

### 2. String Standardization — `TRIM` and `UPPER`

API data is inconsistent. Stock symbols may arrive as `aapl`, `AAPL`, ` AAPL `, or `Aapl` depending on the source and the load run.

```sql
TRIM(UPPER(symbol)) AS symbol,
TRIM(UPPER(related)) AS symbol   -- news table uses RELATED for the ticker
```

**Why it matters:** A JOIN between `fct_daily_stocks` and `raw_news` on `symbol = related` will silently drop rows if case or whitespace doesn't match. You won't get an error — you'll just get wrong counts.

---

### 3. Null Handling — `COALESCE`

Some columns are nullable by design (a day with no precipitation, a missing wind reading). `COALESCE` substitutes a sensible default so downstream aggregations don't silently return `NULL`.

```sql
COALESCE(precip, 0)     AS precip,
COALESCE(max_wind, 0)   AS max_wind
```

**Why it matters:** `AVG(precip)` over 30 days where 5 days have `NULL` returns the average of 25 values, not 30. That's a silent data quality issue that will never surface as an error.

---

### 4. Deduplication — `QUALIFY ROW_NUMBER()`

This is the most important pattern in staging.

Airflow DAGs run on a schedule. If a DAG runs twice, or an API returns overlapping results, duplicate rows land in RAW. Your fact tables have a defined grain (one row per symbol per date, one row per city per date). A single duplicate in staging breaks that grain before the warehouse model ever runs.

`QUALIFY` is a Snowflake-specific clause that filters rows based on a window function result — without a subquery.

#### The Pattern

```sql
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY <natural key columns>
    ORDER BY <tiebreaker — most recent load wins>
) = 1
```

- **`PARTITION BY`** — the columns that define one unique record (the natural key)
- **`ORDER BY`** — when duplicates exist, which one to keep (latest timestamp wins)
- **`= 1`** — keep only the first row per partition

#### Applied to Each Source Table

**Stocks** — one row per symbol per trading date:
```sql
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY symbol, trade_date
    ORDER BY trade_date DESC
) = 1
```

**News** — one row per article ID:
```sql
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id
    ORDER BY datetime DESC
) = 1
```

**Weather** — one row per city per date:
```sql
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY city, date
    ORDER BY date DESC
) = 1
```

#### Why `QUALIFY` Instead of a Subquery

Without `QUALIFY` you would need to write:

```sql
SELECT * FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY symbol, trade_date ORDER BY trade_date DESC) AS rn
    FROM {{ source('snowbearair', 'LASTN_FI_STOCKS') }}
)
WHERE rn = 1
```

`QUALIFY` collapses this into a single clean clause at the end of your `SELECT`. It reads the same way a `WHERE` clause reads — applied after the window function runs.

---

## Putting It All Together

A complete staging model applies all four patterns. The order matters — cast first, then clean, then deduplicate:

```sql
SELECT
    -- 1. Cast types explicitly (use :: for known-safe conversions)
    datetime::DATE AS trade_date,
    open::FLOAT AS open,
    high::FLOAT AS high,
    low::FLOAT AS low,
    close::FLOAT AS close,
    volume::NUMBER(38,0) AS volume,

    -- 2. Standardize strings
    TRIM(UPPER(symbol)) AS symbol

FROM {{ source('snowbearair', 'LASTN_FI_STOCKS') }}

-- 3. Deduplicate — one row per symbol per trading date, latest wins
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY symbol, trade_date
    ORDER BY trade_date DESC
) = 1
```

Note: `COALESCE` is not needed for stocks because `OPEN`, `HIGH`, `LOW`, `CLOSE`, and `VOLUME` are tested as `not_null` at the source. Apply `COALESCE` where your source tests permit nulls — weather columns are the primary case here.

---

## How to Verify Your Work

After running `dbt run` on your staging models, check your work in Snowflake:

```sql
-- Did deduplication work? This should return 0 rows.
SELECT symbol, trade_date, COUNT(*)
FROM STAGING.RAW_STOCKS
GROUP BY symbol, trade_date
HAVING COUNT(*) > 1;

-- Did type casting work? This should return a DATE, not a string.
DESCRIBE TABLE STAGING.RAW_STOCKS;

-- Did string standardization work? This should return no lowercase symbols.
SELECT DISTINCT symbol
FROM STAGING.RAW_STOCKS
WHERE symbol != UPPER(symbol);
```

If any of these return rows, go back to your staging model and fix it before building the warehouse. You cannot trust downstream aggregations built on uncleaned data.

---

## The Downstream Payoff

Once staging is clean and tested, your warehouse models become simpler. `fct_daily_stocks` does not need to handle duplicates, cast types, or guard against nulls — it just joins and aggregates. Your marts do not need to filter bad data — they just answer business questions.

Every hour you spend making staging correct saves three hours of debugging in the warehouse and marts. This is the Toyota principle applied to data: build quality in at the source, don't inspect it at the end.
