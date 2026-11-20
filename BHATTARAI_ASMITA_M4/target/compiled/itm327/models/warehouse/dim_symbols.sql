-- ============================================================
-- dim_symbols
-- Dimension table: one row per unique stock symbol
-- Grain: SYMBOL
-- Source: PROJECT_DB.MODELED.raw_stocks_BHATTARAI_A
-- ============================================================
--
-- Contains descriptive attributes about each ticker derived from
-- the full trading history in your dataset. Marts join against
-- this table to enrich stock performance data with symbol-level
-- context such as all-time highs and historical averages.
--
-- In a production DW you would enrich this with a reference API
-- (e.g., company name, sector, market cap). For this project
-- derive what you can from the data you have.
--
-- COLUMNS TO BUILD:
--
--   Key:
--     SYMBOL
--
--   Date range this symbol appears in your dataset:
--     FIRST_SEEN_DATE     — earliest TRADE_DATE for this symbol
--     LAST_SEEN_DATE      — latest TRADE_DATE for this symbol
--     TOTAL_TRADING_DAYS  — count of trading days in your dataset
--
--   Price statistics across the full history:
--     ALL_TIME_HIGH    — highest HIGH value ever recorded
--     ALL_TIME_LOW     — lowest LOW value ever recorded
--     AVG_CLOSE_PRICE  — average closing price across all days
--
--   Volume:
--     AVG_DAILY_VOLUME  — average trading volume (useful for filtering
--                         inactive tickers)
--
-- HINT:
--   This table has one row per SYMBOL. Think about what that means
--   for your GROUP BY and which functions collapse multiple trading
--   days into a single descriptive row.
--
-- HINT:
--   ALL_TIME_HIGH is used downstream in the DA mart to calculate
--   how far each day's close is from the peak. Make sure your
--   aggregation captures the true maximum across all history.
--
-- ============================================================

SELECT
    -- Key (grain: one row per SYMBOL)
    SYMBOL,

    -- Date range this symbol appears in my data
    MIN(TRADE_DATE)                 AS FIRST_SEEN_DATE,
    MAX(TRADE_DATE)                 AS LAST_SEEN_DATE,
    COUNT(DISTINCT TRADE_DATE)      AS TOTAL_TRADING_DAYS,

    -- Price statistics across the full history
    MAX(HIGH)                       AS ALL_TIME_HIGH,
    MIN(LOW)                        AS ALL_TIME_LOW,
    ROUND(AVG(CLOSE), 4)            AS AVG_CLOSE_PRICE,

    -- Volume
    ROUND(AVG(VOLUME), 0)           AS AVG_DAILY_VOLUME

FROM PROJECT_DB.MODELED.raw_stocks_BHATTARAI_A
GROUP BY SYMBOL