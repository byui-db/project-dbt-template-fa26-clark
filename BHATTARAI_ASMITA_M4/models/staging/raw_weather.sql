-- Staging: daily weather, one row per CITY + DATE
SELECT
    -- 1. Type casting
    DATE::DATE                         AS date,
    MAX_TEMP::FLOAT                    AS max_temp,
    MIN_TEMP::FLOAT                    AS min_temp,
    MAX_TEMP_F::FLOAT                  AS max_temp_f,
    MIN_TEMP_F::FLOAT                  AS min_temp_f,
    AVG_TEMP_C::FLOAT                  AS avg_temp_c,
    TEMP_RANGE_C::FLOAT                AS temp_range_c,
    WEATHER_CODE::NUMBER(38,0)         AS weather_code,
    IS_RAINY::BOOLEAN                  AS is_rainy,
    LOAD_TS::TIMESTAMP_NTZ             AS load_ts,

    -- 2. String standardization ("new york " -> "New York")
    INITCAP(TRIM(CITY))                AS city,

    -- 3. Null handling: a missing reading means none was recorded -> 0
    COALESCE(PRECIP, 0)::FLOAT         AS precip,
    COALESCE(RAIN, 0)::FLOAT           AS rain,
    COALESCE(SNOWFALL, 0)::FLOAT       AS snowfall,
    COALESCE(PRECIP_HOURS, 0)::FLOAT   AS precip_hours,
    COALESCE(MAX_WIND, 0)::FLOAT       AS max_wind,
    COALESCE(MAX_GUST, 0)::FLOAT       AS max_gust

FROM {{ source('snowbearair', 'API_WEATHER_BHATTARAI_A') }}

-- 3. Null handling: drop rows missing the natural key
WHERE CITY IS NOT NULL
  AND DATE IS NOT NULL

-- 4. Deduplication: one row per city per day, most recently loaded wins
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY INITCAP(TRIM(CITY)), DATE
    ORDER BY LOAD_TS DESC
) = 1
