-- Staging: daily stock prices, one row per SYMBOL + TRADE_DATE
SELECT
    -- 1. Type casting (explicit types for every column)
    TRADE_DATE::DATE             AS trade_date,
    OPEN::FLOAT                  AS open,
    HIGH::FLOAT                  AS high,
    LOW::FLOAT                   AS low,
    CLOSE::FLOAT                 AS close,
    VOLUME::NUMBER(38,0)         AS volume,
    DAILY_CHANGE::FLOAT          AS daily_change,
    DAILY_CHANGE_PCT::FLOAT      AS daily_change_pct,
    LOAD_TS::TIMESTAMP_NTZ       AS load_ts,

    -- 2. String standardization (aapl / " AAPL " -> AAPL)
    TRIM(UPPER(SYMBOL))          AS symbol

FROM PROJECT_DB.RAW.MONGO_STOCK_BHATTARAI_A

-- 3. Null handling: drop rows missing the natural key
WHERE SYMBOL IS NOT NULL
  AND TRADE_DATE IS NOT NULL

-- 4. Deduplication: one row per symbol per day, most recently loaded wins
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY TRIM(UPPER(SYMBOL)), TRADE_DATE
    ORDER BY LOAD_TS DESC
) = 1