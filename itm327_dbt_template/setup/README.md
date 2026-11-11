# Instructor Setup — ITM327 dbt Template

> **FA26:** the account is stood up by the notebooks in `itm327_anskey` (`admin_setup.ipynb` / `student_setup.ipynb`), not this script. `snowflake_setup.sql` and the `SNOWBEARAIR_DB` / `TRAINING_ROLE` names below are from the previous account and are kept for reference only.

> **Students:** This folder is not part of your project work. Nothing here needs to be run or modified by you. Your work begins in `models/staging/`.

---

## What This Is

`snowflake_setup.sql` is a one-time Snowflake configuration script run by the instructor before students begin Sprint 5. It creates the pipeline schemas, sets permissions, and verifies the environment is ready.

Run this as `ACCOUNTADMIN` in a Snowflake worksheet — not through dbt.

---

## Pipeline Schema Architecture

```
SNOWBEARAIR_DB
│
├── RAW       ← Airflow writes here — dbt reads only, never writes
├── STAGING   ← dbt dev target (default) — your dev build of all models lands here
└── MODELED   ← dbt prod target — the production build of all models lands here
```

---

## Pre-Flight Checklist

Run through these before students begin M4:

**Step 1 — Run `snowflake_setup.sql`**
Execute the full script as `ACCOUNTADMIN`. Confirm no errors on schema creation or grant statements.

**Step 2 — Verify RAW tables exist**
```sql
SHOW TABLES IN SCHEMA SNOWBEARAIR_DB.RAW;
```
Expected: `LASTN_FI_STOCKS`, `LASTN_FI_NEWS`, `LASTN_FI_WEATHER` (with student prefix). If missing, Airflow DAGs from S1–S4 have not run successfully.

**Step 3 — Verify TRAINING_ROLE can read RAW**
```sql
USE ROLE TRAINING_ROLE;
SELECT COUNT(*) FROM SNOWBEARAIR_DB.RAW.LASTN_FI_STOCKS;
```
If this fails, the RAW SELECT grant did not apply correctly.

**Step 4 — Verify Cortex access**
```sql
SELECT SNOWFLAKE.CORTEX.SENTIMENT('the market is performing well today');
```
Expected: a decimal score between -1 and 1. If this fails, the Cortex grant is missing or your Snowflake edition does not support Cortex. Cortex is required for the DS mart in M7.

**Step 5 — Have a student run dbt commands in order**
```bash
dbt deps      # no external packages — prints "No packages were found", which is expected, not an error
dbt debug     # validates connection, profiles.yml, and dbt installation
dbt compile   # validates all SQL/Jinja without writing to Snowflake
dbt run       # default target (dev) — builds all models into STAGING
dbt run --target prod   # builds all models into MODELED
dbt test      # runs all tests across all layers
```

**Step 6 — Confirm schema routing**
```sql
-- Staging views should appear here
SHOW VIEWS IN SCHEMA SNOWBEARAIR_DB.STAGING;

-- Warehouse and mart tables should appear here
SHOW TABLES IN SCHEMA SNOWBEARAIR_DB.MODELED;

-- This should be unchanged — dbt never writes to RAW
SHOW OBJECTS IN SCHEMA SNOWBEARAIR_DB.RAW;
```

---

## profiles.yml Note

`profiles.yml` ships with `account: 'not needed'` and `user: 'not needed'`. This is intentional for Snowflake's native dbt environment where the session handles authentication. If students are running dbt locally they will need to update these fields with their Snowflake account identifier and username, and add an `authenticator` field appropriate for your org's auth method.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `dbt debug` fails | profiles.yml missing account/user | Update auth fields for local dbt |
| `dbt deps` can't download a package (demo/tb_101 or `dbt_utils`) | Workspaces blocks the package-hub network call unless an External Access Integration is selected | In the run popover, select the **`dbt_access_integration`** integration (created in setup step 8; the name matches the Snowflake dbt guide + Tasty Bytes demo). This template has no packages, so deps is a no-op and needs no EAI. |
| `dbt run` fails on staging | STAGING schema missing | Re-run setup SQL |
| `dbt run --target prod` fails | MODELED schema missing or no write access | Re-run grants in setup SQL |
| Cortex `SENTIMENT()` fails | Cortex grant missing or unsupported edition | Verify Cortex grant, check Snowflake edition |
| RAW tables not found | Student prefix mismatch | Verify `__sources.yml` prefix matches actual table names |
