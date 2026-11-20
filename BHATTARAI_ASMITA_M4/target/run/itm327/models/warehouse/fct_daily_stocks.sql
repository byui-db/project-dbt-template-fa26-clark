
  
    

        create or replace transient table PROJECT_DB.MODELED.fct_daily_stocks_BHATTARAI_A
         as
        (-- ============================================================
-- fct_daily_stocks
-- Fact table: one row per stock symbol per trading day
-- Grain: SYMBOL + TRADE_DATE
-- Source: PROJECT_DB.MODELED.raw_stocks_BHATTARAI_A
-- ============================================================
--
-- This is the central price fact table of your data warehouse.
-- It contains stock price data and derived price metrics only.
-- News data lives in its own warehouse models (dim_news, fct_daily_news)
-- and is joined to this table at the mart layer.
--
-- Marts must reference this table via ref() — never reach back
-- to staging directly.
--
-- COLUMNS TO BUILD:
--
--   Keys:
--     SYMBOL, TRADE_DATE
--
--   Price metrics (from raw_stocks):
--     OPEN, HIGH, LOW, CLOSE, VOLUME
--
--   Derived price metrics (calculate here so marts don't repeat logic):
--     DAILY_RANGE   — the spread between HIGH and LOW
--     DAILY_CHANGE  — the difference between CLOSE and OPEN
--     PCT_CHANGE    — DAILY_CHANGE as a percentage of OPEN (round to 4 decimals)
--                     Hint: guard against division by zero
--     DIRECTION     — 'UP', 'DOWN', or 'FLAT' based on CLOSE vs OPEN
--
-- HINT:
--   This model has no JOIN and no aggregation — one row in raw_stocks
--   produces one row here. Focus on getting the derived metrics right.
--   The DIRECTION CASE statement will be tested in Sprint 6.
--
-- ============================================================

SELECT
    -- Keys (grain: one row per SYMBOL + TRADE_DATE)
    SYMBOL,
    TRADE_DATE,

    -- Price metrics
    OPEN,
    HIGH,
    LOW,
    CLOSE,
    VOLUME,

    -- Derived price metrics
    ROUND(HIGH - LOW, 4)                                    AS DAILY_RANGE,
    ROUND(CLOSE - OPEN, 4)                                  AS DAILY_CHANGE,
    ROUND(DIV0(CLOSE - OPEN, OPEN) * 100, 4)                AS PCT_CHANGE,
    CASE
        WHEN CLOSE > OPEN THEN 'UP'
        WHEN CLOSE < OPEN THEN 'DOWN'
        ELSE 'FLAT'
    END                                                     AS DIRECTION

FROM PROJECT_DB.MODELED.raw_stocks_BHATTARAI_A
        );
      
  