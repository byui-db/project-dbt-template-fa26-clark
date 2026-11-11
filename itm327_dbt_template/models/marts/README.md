# Marts Layer — Client-Facing Data Products

## What Marts Are

Marts are the final layer of your pipeline — the data products your clients actually consume. Each mart answers a specific business question for a specific audience. Unlike the warehouse which is generic and reusable, a mart is opinionated: it is built for one client with one purpose.

Every model here lands in the **shared** `MODELED` schema, tagged with your `student_prefix`
(e.g. `STOCK_NEWS_DAILY_SMITHJ`) so it doesn't overwrite a classmate's. See *Customize Your
Table Names* in the root README:

```bash
dbt run --target prod --select marts   # build all marts
dbt run --target prod --select stock_news_daily  # build one mart
```

---

## The One Rule

**Marts must only reference warehouse models via `{{ ref() }}` — never staging.**

```sql
-- CORRECT
FROM {{ ref('fct_daily_stocks') }}

-- WRONG — never reach back to staging from a mart
FROM {{ ref('raw_stocks') }}
```

If you find yourself referencing a staging model from a mart, stop. Find the warehouse model that contains that data and reference it instead. The warehouse exists precisely so marts do not have to touch raw data.

---

## Your Two Marts

### DA Mart — SQL Model

**Client:** A Data Analyst who works in SQL and BI tools. They need a clean, pre-joined table they can query directly without writing complex aggregations themselves.

Choose **one** of the following:

| Mart | Business Question |
|------|------------------|
| `stock_news_daily.sql` | How did each stock perform daily, was it news-driven, and how far is it from its all-time high? |
| `weather_market_conditions.sql` | How did weather at financial hub cities relate to broad market performance? |

### DS Mart — Python Model

**Client:** A Data Scientist building a stock risk screening model. They need one summary row per symbol with pre-computed statistical features they can feed into a machine learning pipeline.

| Mart | Business Question |
|------|------------------|
| `market_volatility_metrics.py` | Which stocks are most volatile, which direction do they trend, and what does news sentiment tell us about market perception? |

---

## The Grain Mismatch Problem — dim_news in Marts

`dim_news` is at **article grain** — one row per article. Your fact tables are at **SYMBOL + DATE grain** — one row per stock per day. You cannot join them directly without creating fan-out (multiple rows per stock day).

**Solve this in a CTE before your main JOIN:**

```sql
WITH news_by_day AS (
    SELECT
        SYMBOL,
        DATE_KEY,
        COUNT(*)  AS NEWS_ARTICLE_COUNT,
        LISTAGG(HEADLINE, ' | ') WITHIN GROUP (ORDER BY PUBLISHED_AT) AS HEADLINES
    FROM {{ ref('dim_news') }}
    GROUP BY SYMBOL, DATE_KEY
)

SELECT
    f.*,
    n.NEWS_ARTICLE_COUNT,
    n.HEADLINES
FROM {{ ref('fct_daily_stocks') }} f
LEFT JOIN news_by_day n
    ON f.SYMBOL = n.SYMBOL
    AND f.TRADE_DATE = n.DATE_KEY
```

The CTE collapses articles to `SYMBOL + DATE` grain before the JOIN. No fan-out, no duplicates.

**Why LISTAGG?** Cortex `SENTIMENT()` in your DS mart expects a string — all headlines for a symbol on a given day concatenated together. Think carefully about your separator so the string reads naturally.

---

## SQL vs Python — When to Use Each

| | SQL Mart | Python Mart |
|--|----------|-------------|
| **Use when** | Joins, aggregations, CASE logic, Cortex functions | Statistical computation (stddev, complex window functions), Snowpark DataFrames |
| **Returns** | Table built from SELECT | Snowpark DataFrame |
| **References warehouse** | `{{ ref('model_name') }}` | `dbt.ref('model_name')` |

Cortex `SENTIMENT()` is a SQL function — you can call it from inside a Python model using `session.sql()`. Python and SQL are not mutually exclusive inside Snowflake.

---

## Schema Tests

Create `models/marts/marts_tests.yml` to validate your mart models. See `tests/README.md` for the full breakdown.

Key tests for this layer:
- `not_null` on primary key columns
- `dbt_utils.unique_combination_of_columns` on composite primary keys
- At least one additional column-level test of your choice

Singular SQL tests for your mart go in the `tests/` folder — not here. See `tests/README.md` for which singular tests are required and when to write them.
