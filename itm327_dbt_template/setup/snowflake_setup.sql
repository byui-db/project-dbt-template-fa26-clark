-- =============================================================
-- ITM327 dbt Project — Instructor Setup
-- Run this once in Snowflake as an admin before students begin.
-- Students do not run this file.
-- =============================================================

-- -------------------------------------------------------
-- 1. Use admin role and warehouse
-- -------------------------------------------------------
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ANIMAL_TASK_WH;
USE DATABASE SNOWBEARAIR_DB;

-- -------------------------------------------------------
-- 2. Create the three pipeline schemas
--    RAW already exists — Airflow DAGs write there.
--    STAGING and MODELED are created here for dbt output.
-- -------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS SNOWBEARAIR_DB.STAGING;
CREATE SCHEMA IF NOT EXISTS SNOWBEARAIR_DB.MODELED;

-- -------------------------------------------------------
-- 3. Grant RAW read access to TRAINING_ROLE
--    dbt reads from RAW but never writes to it.
-- -------------------------------------------------------
GRANT USAGE  ON SCHEMA SNOWBEARAIR_DB.RAW TO ROLE TRAINING_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWBEARAIR_DB.RAW TO ROLE TRAINING_ROLE;

-- Ensure future tables loaded by Airflow are also readable
GRANT SELECT ON FUTURE TABLES IN SCHEMA SNOWBEARAIR_DB.RAW TO ROLE TRAINING_ROLE;

-- -------------------------------------------------------
-- 4. Grant STAGING write access to TRAINING_ROLE
--    dbt's dev/build environment — default target: dev → STAGING
-- -------------------------------------------------------
GRANT USAGE       ON SCHEMA SNOWBEARAIR_DB.STAGING TO ROLE TRAINING_ROLE;
GRANT CREATE TABLE ON SCHEMA SNOWBEARAIR_DB.STAGING TO ROLE TRAINING_ROLE;
GRANT CREATE VIEW  ON SCHEMA SNOWBEARAIR_DB.STAGING TO ROLE TRAINING_ROLE;

-- -------------------------------------------------------
-- 5. Grant MODELED write access to TRAINING_ROLE
--    dbt's production environment — target: prod → MODELED
-- -------------------------------------------------------
GRANT USAGE        ON SCHEMA SNOWBEARAIR_DB.MODELED TO ROLE TRAINING_ROLE;
GRANT CREATE TABLE ON SCHEMA SNOWBEARAIR_DB.MODELED TO ROLE TRAINING_ROLE;
GRANT CREATE VIEW  ON SCHEMA SNOWBEARAIR_DB.MODELED TO ROLE TRAINING_ROLE;

-- -------------------------------------------------------
-- 6. Grant Cortex AI access to TRAINING_ROLE
--    Required for SNOWFLAKE.CORTEX.SENTIMENT() in the DS mart
-- -------------------------------------------------------
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE TRAINING_ROLE;

-- -------------------------------------------------------
-- 7. Grant warehouse compute access
-- -------------------------------------------------------
GRANT USAGE ON WAREHOUSE ANIMAL_TASK_WH TO ROLE TRAINING_ROLE;

-- -------------------------------------------------------
-- 8. External Access Integration for `dbt deps`
--    THIS TEMPLATE needs NO packages — students can skip `dbt deps`
--    entirely. But the dbt demo (tb_101) DOES use dbt_utils, and in
--    Snowflake Workspaces `dbt deps` is blocked from reaching the
--    package hub unless an External Access Integration is selected in
--    the run popover.
--
--    Canonical names match the Snowflake "dbt Projects on Snowflake"
--    guide and the Tasty Bytes dbt demo: integration
--    `dbt_access_integration`, network rule `dbt_network_rule`.
--    On the shared training account the course instructor setup already
--    provisions this account-wide, so IF NOT EXISTS makes these no-ops
--    there; they keep a fresh standalone account self-contained.
-- -------------------------------------------------------
CREATE NETWORK RULE IF NOT EXISTS SNOWBEARAIR_DB.RAW.dbt_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('hub.getdbt.com', 'codeload.github.com');

CREATE EXTERNAL ACCESS INTEGRATION IF NOT EXISTS dbt_access_integration
  ALLOWED_NETWORK_RULES = (SNOWBEARAIR_DB.RAW.dbt_network_rule)
  ENABLED = TRUE;

GRANT USAGE ON INTEGRATION dbt_access_integration TO ROLE TRAINING_ROLE;

-- -------------------------------------------------------
-- 9. Verify setup — run these to confirm before class
-- -------------------------------------------------------

-- Confirm schemas exist
SHOW SCHEMAS IN DATABASE SNOWBEARAIR_DB;

-- Confirm RAW tables are present (loaded by Airflow)
SHOW TABLES IN SCHEMA SNOWBEARAIR_DB.RAW;

-- Confirm TRAINING_ROLE can read RAW
USE ROLE TRAINING_ROLE;
SELECT COUNT(*) FROM SNOWBEARAIR_DB.RAW.LASTN_FI_STOCKS;
SELECT COUNT(*) FROM SNOWBEARAIR_DB.RAW.LASTN_FI_NEWS;
SELECT COUNT(*) FROM SNOWBEARAIR_DB.RAW.LASTN_FI_WEATHER;

-- Confirm Cortex is accessible
SELECT SNOWFLAKE.CORTEX.SENTIMENT('the market is performing well today') AS TEST_SENTIMENT;

-- Switch back to admin when done
USE ROLE ACCOUNTADMIN;
