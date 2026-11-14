
  
    

        create or replace transient table PROJECT_DB.STAGING.dim_news_BHATTARAI_A
         as
        (-- ============================================================
-- dim_news
-- Dimension table: one row per news article
-- Grain: ID (unique article identifier)
-- Source: PROJECT_DB.STAGING.raw_news_BHATTARAI_A
-- ============================================================
--
-- News articles are dimension data — they are rich with descriptive
-- string attributes (headline, category, source, summary) and contain
-- very few numeric measures. This makes them a natural dimension.
--
-- This table preserves one clean row per article. The aggregation
-- of news articles up to SYMBOL + DATE grain happens in the mart
-- layer, not here — different marts may aggregate news differently.
--
-- JOIN KEYS (how this table connects to the rest of the warehouse):
--
--   → dim_date      via DATE_KEY  (cast PUBLISHED_AT to DATE)
--   → dim_symbols   via SYMBOL    (from RELATED column in raw_news)
--   → fct_daily_stocks via SYMBOL + DATE_KEY (in the mart layer)
--
-- COLUMNS TO BUILD:
--
--   Key:
--     ID  — unique article identifier
--
--   Foreign keys:
--     SYMBOL    — stock ticker this article is about
--                 Hint: sourced from RELATED in raw_news
--                 Apply the same TRIM(UPPER()) standardization as raw_stocks
--     DATE_KEY  — calendar date of publication (cast PUBLISHED_AT to DATE)
--                 Joins to dim_date
--
--   Descriptive attributes:
--     PUBLISHED_AT  — full publication datetime (cast to TIMESTAMP)
--     HEADLINE      — article headline
--     CATEGORY      — type of news coverage
--     SOURCE        — publisher name
--     SUMMARY       — article summary
--     URL           — link to full article
--
-- MART HINT:
--   In your DA mart and DS mart, you will aggregate this table to
--   SYMBOL + DATE_KEY grain using LISTAGG for HEADLINE before joining
--   to fct_daily_stocks. The LISTAGG string is what Cortex SENTIMENT()
--   will consume in your DS mart — it expects a string, not an array.
--
-- ============================================================

-- TODO: Write your SELECT statement below
select 1 as placeholder  -- placeholder so the template compiles; DELETE this line when you write your own SELECT
        );
      
  