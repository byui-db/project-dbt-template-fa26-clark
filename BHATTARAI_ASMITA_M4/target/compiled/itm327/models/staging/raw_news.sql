-- Staging: financial news articles, one row per article ID
SELECT
    -- 1. Type casting
    ID::VARCHAR                        AS id,
    PUBLISHED_AT::TIMESTAMP_NTZ        AS published_at,
    NEWS_DATE::DATE                    AS news_date,
    LOAD_TS::TIMESTAMP_NTZ             AS load_ts,

    -- 2. String standardization
    TRIM(UPPER(TICKER))                AS symbol,      -- matches stocks.symbol for joins
    TRIM(HEADLINE)                     AS headline,
    LOWER(TRIM(CATEGORY))              AS category,
    TRIM(SOURCE)                       AS source,
    TRIM(URL)                          AS url,
    TRIM(IMAGE)                        AS image,

    -- 3. Null handling: optional text gets a clear default
    COALESCE(TRIM(SUMMARY), '')        AS summary

FROM PROJECT_DB.RAW.SFTP_NEWS_BHATTARAI_A

-- 3. Null handling: an article without an ID or headline is unusable
WHERE ID IS NOT NULL
  AND HEADLINE IS NOT NULL

-- 4. Deduplication: one row per article, most recently loaded wins
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ID
    ORDER BY LOAD_TS DESC
) = 1