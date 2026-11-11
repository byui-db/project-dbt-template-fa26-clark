# IMPORTANT: Staging README Update (2026-07-08)

## Issue

The previous version of `models/staging/README.md` incorrectly instructed students to use `TRY_CAST` for **all** type conversions.

This causes **compile errors** in Snowflake for compile-time safe conversions:

```sql
-- ❌ CAUSES COMPILE ERROR
TRY_CAST(id AS VARCHAR)           -- NUMBER → VARCHAR
TRY_CAST(datetime AS DATE)        -- TIMESTAMP → DATE
TRY_CAST(temperature AS NUMBER)   -- FLOAT → NUMBER
```

Error message:
```
Function TRY_CAST cannot be used with arguments of types NUMBER(38,0) and VARCHAR
```

## Fix

The README has been updated to distinguish between:
- **`::` syntax** - for compile-time safe conversions (always work)
- **`TRY_CAST`** - for runtime conversions that might fail (e.g., `'abc'` → NUMBER)

## Action Required

If you've already written your staging models using `TRY_CAST`, update them to use `::` syntax:

### Before (incorrect)
```sql
SELECT
    TRY_CAST(id AS VARCHAR) AS id,
    TRY_CAST(headline AS VARCHAR) AS headline,
    TRY_CAST(datetime AS TIMESTAMP) AS datetime
FROM {{ source('snowbearair', 'RANDALLJ_NEWS') }}
```

### After (correct)
```sql
SELECT
    id::VARCHAR AS id,
    headline::VARCHAR AS headline,
    datetime::TIMESTAMP AS datetime
FROM {{ source('snowbearair', 'RANDALLJ_NEWS') }}
```

## When to Use Each

| Conversion | Use | Example |
|------------|-----|---------|
| NUMBER → VARCHAR | `::` | `id::VARCHAR` |
| TIMESTAMP → DATE | `::` | `datetime::DATE` |
| FLOAT → NUMBER | `::` | `temperature::NUMBER(38,0)` |
| FLOAT → FLOAT | `::` | `open::FLOAT` |
| VARCHAR → NUMBER | `TRY_CAST` | `TRY_CAST(price_str AS FLOAT)` |
| VARCHAR → DATE | `TRY_CAST` | `TRY_CAST(date_str AS DATE)` |

**Rule**: If the source column **always** has valid data for the target type, use `::`. If it **might** be invalid, use `TRY_CAST`.

## For This Course

All three raw tables (news, stocks, weather) use **known types** from Airflow. Use `::` syntax for all conversions:

```sql
-- ✅ Raw stocks
datetime::TIMESTAMP AS datetime,
symbol::VARCHAR AS symbol,
open::FLOAT AS open,
volume::NUMBER(38,0) AS volume

-- ✅ Raw news
id::VARCHAR AS id,
headline::VARCHAR AS headline,
datetime::TIMESTAMP AS datetime

-- ✅ Raw weather
city::VARCHAR AS city,
datetime::TIMESTAMP AS datetime,
temperature::FLOAT AS temperature
```

## Updated README

See `itm327_dbt_template/models/staging/README.md` section "1. Type Casting" for complete guidance.

---

**This update fixes compile errors reported 2026-07-08.**
