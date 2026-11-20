
  
    

        create or replace transient table PROJECT_DB.MODELED.dim_weather_cities_BHATTARAI_A
         as
        (-- ============================================================
-- dim_weather_cities
-- Dimension table: one row per financial hub city
-- Grain: CITY
-- Source: PROJECT_DB.MODELED.raw_weather_BHATTARAI_A
-- ============================================================
--
-- Contains climatological statistics for each city tracked by
-- your weather pipeline. Marts that analyze market performance
-- by geography join against this table to compare current
-- conditions against historical norms for that city.
--
-- COLUMNS TO BUILD:
--
--   Key:
--     CITY
--
--   Date range this city appears in your weather data:
--     FIRST_OBSERVATION_DATE  — earliest DATE for this city
--     LAST_OBSERVATION_DATE   — latest DATE for this city
--     TOTAL_OBSERVATION_DAYS  — count of observation days
--
--   Typical conditions (averages across the full history):
--     AVG_MAX_TEMP      — round to 2 decimal places
--     AVG_MIN_TEMP      — round to 2 decimal places
--     AVG_DAILY_PRECIP  — round to 2 decimal places
--     AVG_MAX_WIND      — round to 2 decimal places
--
--   Extreme conditions:
--     HOTTEST_DAY_TEMP    — highest MAX_TEMP ever recorded
--     COLDEST_DAY_TEMP    — lowest MIN_TEMP ever recorded
--     WETTEST_DAY_PRECIP  — highest single day precipitation
--
-- HINT:
--   Like dim_symbols, this table collapses many daily rows into
--   one descriptive row per CITY. The average columns become the
--   "normal" baseline that your weather mart uses to calculate
--   how much today's conditions deviate from historical norms.
--
-- HINT:
--   Add a city-to-exchange mapping if you want to associate each
--   city with a specific stock exchange (e.g., New York → NYSE/NASDAQ).
--
-- ============================================================

SELECT
    -- Key (grain: one row per CITY)
    CITY,

    -- Which stock exchange this financial hub is home to
    CASE CITY
        WHEN 'New York' THEN 'NYSE / NASDAQ'
        WHEN 'London'   THEN 'LSE'
        WHEN 'Tokyo'    THEN 'TSE'
        ELSE 'UNKNOWN'
    END                                 AS EXCHANGE,

    -- Date range this city appears in my weather data
    MIN(DATE)                           AS FIRST_OBSERVATION_DATE,
    MAX(DATE)                           AS LAST_OBSERVATION_DATE,
    COUNT(DISTINCT DATE)                AS TOTAL_OBSERVATION_DAYS,

    -- Typical conditions (averages across full history)
    ROUND(AVG(MAX_TEMP), 2)             AS AVG_MAX_TEMP,
    ROUND(AVG(MIN_TEMP), 2)             AS AVG_MIN_TEMP,
    ROUND(AVG(PRECIP), 2)               AS AVG_DAILY_PRECIP,
    ROUND(AVG(MAX_WIND), 2)             AS AVG_MAX_WIND,

    -- Extreme conditions
    MAX(MAX_TEMP)                       AS HOTTEST_DAY_TEMP,
    MIN(MIN_TEMP)                       AS COLDEST_DAY_TEMP,
    MAX(PRECIP)                         AS WETTEST_DAY_PRECIP

FROM PROJECT_DB.MODELED.raw_weather_BHATTARAI_A
GROUP BY CITY
        );
      
  