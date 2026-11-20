-- ============================================================
-- fct_daily_weather
-- Fact table: one row per city per observation day
-- Grain: CITY + DATE
-- Source: PROJECT_DB.MODELED.raw_weather_BHATTARAI_A
-- ============================================================
--
-- Accepts cleaned weather readings from staging into the warehouse
-- layer. This is the simplest fact table in the project — it is
-- largely a pass-through from staging with the grain explicitly
-- defined. Marts that need weather data must reference this table
-- via ref(), never reach back to raw_weather directly.
--
-- COLUMNS TO BUILD:
--
--   Keys:
--     DATE, CITY
--
--   Weather measurements (from raw_weather):
--     MAX_TEMP, MIN_TEMP, PRECIP, MAX_WIND
--
-- HINT:
--   Unlike fct_daily_stocks, this fact table does not require a JOIN
--   or aggregation. Focus on selecting and naming your columns clearly.
--   If your weather pipeline adds new columns (e.g., humidity, UV index)
--   add them here so marts inherit them automatically.
--
-- ============================================================

SELECT
    -- Keys (grain: one row per CITY + DATE)
    DATE,
    CITY,

    -- Weather measurements
    MAX_TEMP,
    MIN_TEMP,
    PRECIP,
    MAX_WIND,

    -- Extra measurements from my pipeline (so marts inherit them)
    MAX_GUST,
    RAIN,
    SNOWFALL,
    PRECIP_HOURS,
    AVG_TEMP_C,
    TEMP_RANGE_C,
    IS_RAINY

FROM PROJECT_DB.MODELED.raw_weather_BHATTARAI_A