-- ============================================================
-- dim_date
-- Dimension table: one row per calendar date
-- Grain: DATE_KEY
-- Source: generated — no source table needed
-- ============================================================
--
-- The date dimension is the backbone of your data warehouse.
-- Every fact table (fct_daily_stocks, fct_daily_weather) and
-- every dimension with a date attribute (dim_news) joins through
-- this table. It is what connects all your models together.
--
-- Unlike every other model in this project, dim_date is not built
-- from a source table — it is generated using Snowflake's GENERATOR
-- function which produces a sequence of rows you convert to dates.
--
-- WORKING EXAMPLE — adapt the date range to fit your dataset:
-- TODO: Change the start date and ROWCOUNT to match your data range
--       Check the earliest and latest dates in your RAW tables first

WITH date_spine AS (
    SELECT
        DATEADD(DAY, SEQ4(), '2023-01-01'::DATE) AS DATE_KEY  -- TODO: update start date
    FROM TABLE(GENERATOR(ROWCOUNT => 365 * 5))                 -- TODO: update years to cover your data
)

SELECT
    DATE_KEY,

    -- Day attributes
    DAYNAME(DATE_KEY)                           AS DAY_OF_WEEK_NAME,
    DAYOFWEEKISO(DATE_KEY)                      AS DAY_OF_WEEK_NUM,
    DAY(DATE_KEY)                               AS DAY_OF_MONTH,

    -- Week / Month / Quarter / Year
    WEEKOFYEAR(DATE_KEY)                        AS WEEK_OF_YEAR,
    MONTH(DATE_KEY)                             AS MONTH_NUM,
    MONTHNAME(DATE_KEY)                         AS MONTH_NAME,
    QUARTER(DATE_KEY)                           AS QUARTER,
    YEAR(DATE_KEY)                              AS YEAR,

    -- Business flags
    DAYOFWEEKISO(DATE_KEY) IN (6, 7)            AS IS_WEEKEND,
    DAYOFWEEKISO(DATE_KEY) NOT IN (6, 7)        AS IS_WEEKDAY,
    DAYOFWEEKISO(DATE_KEY) NOT IN (6, 7)        AS IS_TRADING_DAY  -- approximation: excludes weekends
                                                                    -- does not account for market holidays

FROM date_spine
WHERE DATE_KEY <= CURRENT_DATE() + INTERVAL '1 YEAR'  -- TODO: adjust future buffer if needed

-- ============================================================
-- HOW GENERATOR WORKS:
--   TABLE(GENERATOR(ROWCOUNT => N)) produces N rows
--   SEQ4() assigns each row a sequential integer starting at 0
--   DATEADD adds that integer as days to your start date
--   The WHERE clause trims the end so you don't generate
--   unnecessary future dates beyond what you need
--
-- HOW TO FIND YOUR DATE RANGE:
--   Run this in Snowflake to check your source data:
--
--   SELECT MIN(TRADE_DATE), MAX(TRADE_DATE) FROM RAW.LASTN_FI_STOCKS;
--   SELECT MIN(DATE), MAX(DATE) FROM RAW.LASTN_FI_WEATHER;
--
-- TODO: Add additional calendar attributes that would be useful
--       for your analysis (e.g., IS_MONTH_END, IS_QUARTER_END,
--       FISCAL_YEAR if relevant to your business questions)
-- ============================================================