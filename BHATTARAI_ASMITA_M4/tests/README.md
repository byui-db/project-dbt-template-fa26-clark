# Tests — Data Quality at Every Layer

## Why Tests Matter

A pipeline without tests is a pipeline you cannot trust. You might run `dbt run` successfully and still have wrong data — fact tables with duplicate rows, dimension joins that silently drop records, calculated columns with logic errors no one caught.

dbt tests are SQL assertions. They return rows when something is **wrong**. Zero rows returned means the test passed. Any rows returned means the test failed and tells you exactly which records violated the rule.

Tests belong at every layer:

```
RAW (source tests)      — did Airflow load what we expected?
STAGING (schema tests)  — did our cleaning work?
WAREHOUSE (schema tests) — is the dimensional model correct?
MARTS (schema + singular tests) — does our business logic hold?
```

---

## Where Test Files Live in a dbt Project

This is the most important thing to understand before writing any test.

**dbt has two completely separate locations for tests, and they use different file formats:**

```
itm327_dbt_template/
│
├── models/
│   ├── staging/
│   │   ├── raw_stocks.sql
│   │   ├── raw_news.sql
│   │   ├── raw_weather.sql
│   │   ├── __sources.yml        ← source tests live here (RAW layer)
│   │   └── staging_tests.yml   ← staging schema tests live here
│   │
│   ├── warehouse/
│   │   └── warehouse_tests.yml ← warehouse schema tests live here
│   │
│   └── marts/
│       └── marts_tests.yml     ← mart schema tests live here
│
└── tests/
    ├── generic/
    │   └── test_is_positive_amount.sql  ← reusable custom generic tests
    │
    ├── test_direction_matches_daily_change.sql  ← singular tests live here
    ├── test_pct_from_ath_lte_zero.sql
    └── test_direction_counts_sum.sql
```

**The rule:**
- Schema tests → `.yml` files **inside the `models/` folder**, next to the models they test
- Singular tests → `.sql` files **inside the `tests/` folder**
- Custom generic tests → `.sql` files **inside `tests/generic/`**

Schema tests never go in `tests/`. Singular tests never go in `models/`.

---

## The Four Types of dbt Tests

### Type 1 — Built-in Generic Tests (`.yml` in `models/`)

The four tests dbt ships with. Declared in `.yml` files alongside your models. Fast to write, covers the most common data quality checks.

| Test | What It Checks |
|------|---------------|
| `not_null` | Column has no NULL values |
| `unique` | Column has no duplicate values |
| `accepted_values` | Column only contains values from a defined list |
| `relationships` | Every value in a column exists in another model (referential integrity) |

**File location:** `models/staging/staging_tests.yml`

```yaml
models:
  - name: raw_stocks
    columns:
      - name: SYMBOL
        tests:
          - not_null
      - name: TRADE_DATE
        tests:
          - not_null
```

**File location:** `models/warehouse/warehouse_tests.yml`

```yaml
models:
  - name: fct_daily_stocks
    columns:
      - name: DIRECTION
        tests:
          - not_null
          - accepted_values:
              values: ['UP', 'DOWN', 'FLAT']
```

Run with: `dbt test --select raw_stocks` or `dbt test --select fct_daily_stocks`

---

### Type 2 — Custom Generic Tests (`.sql` in `tests/generic/`)

Reusable tests you write once and apply anywhere via `.yml`, just like built-in tests. They live in `tests/generic/` as Jinja SQL macros and are referenced in `.yml` files the same way as built-in tests.

This project already includes one:

**File location:** `tests/generic/test_is_positive_amount.sql`

```sql
{% test is_positive_amount(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} is not null and {{ column_name }} <= 0
{% endtest %}
```

Applied in a `.yml` file just like a built-in test:

```yaml
- name: CLOSE
  tests:
    - is_positive_amount
```

Write a new custom generic test when you find yourself writing the same singular test logic more than once — that's the signal to make it reusable.

---

### Type 3 — Source Tests (`.yml` in `models/staging/`)

Built-in or custom generic tests applied specifically to your **RAW source tables** via `__sources.yml`. These validate Airflow's data before dbt has transformed anything — they catch problems at the entry point of your pipeline.

**File location:** `models/staging/__sources.yml` (already configured in this project)

```yaml
sources:
  - name: snowbearair
    tables:
      - name: LASTN_FI_STOCKS
        columns:
          - name: SYMBOL
            tests:
              - not_null
          - name: CLOSE
            tests:
              - is_positive_amount
```

Source tests are pre-configured in this project. Review `models/staging/__sources.yml` to understand what is already validated at the RAW layer before writing duplicate tests downstream.

---

### Type 4 — Singular Tests (`.sql` in `tests/`)

One-off `.sql` files that live directly in the `tests/` folder. Each file is a query that returns rows when the test **fails**. These are for business logic that cannot be expressed as a generic test — rules specific to your domain and your models.

The structure of every singular test is the same: a `SELECT` that finds rows violating your rule. If the query returns rows, the test fails.

```sql
-- Example structure — your WHERE clause defines the business rule
select *
from {{ ref('your_model') }}
where <condition that should never be true>
```

Singular tests are where you prove your own model logic is correct. They are the highest-value tests you will write because they test *your* business rules, not just column presence.

---

## Your Required Singular Tests

Write these as `.sql` files directly in this `tests/` folder. Use AI to generate the SQL — your job is to understand the rule precisely enough to describe it and interpret what a failure means.

---

### Milestone 6 — DA Mart Singular Tests

Write the test that matches the DA mart you built. If a test returns rows, your mart logic has a bug — trace it before assuming the source data is wrong.

**Test A — PCT_FROM_ATH can never be positive**
*(Write this if you built `stock_news_daily`)*
- **Business rule:** A stock's current close price cannot exceed its all-time high. `PCT_FROM_ATH` must always be zero or negative.
- **On failure:** Either `ALL_TIME_HIGH` is calculated incorrectly in `dim_symbols`, or the JOIN between your mart and the dimension is broken
- **File to create:** `tests/test_pct_from_ath_lte_zero.sql`

---

**Test B — Direction counts must sum to total stocks tracked**
*(Write this if you built `weather_market_conditions`)*
- **Business rule:** `STOCKS_UP + STOCKS_DOWN + STOCKS_FLAT` must equal `STOCKS_TRACKED` for every row. Every stock must be classified exactly once.
- **On failure:** The aggregation counting directions uses a different filter or join condition than the one counting total stocks
- **File to create:** `tests/test_direction_counts_sum.sql`

---

### Milestone 7 — Warehouse Singular Test

Now that you know how to write singular tests, circle back to the warehouse model you built in Milestone 5 before you knew this pattern existed.

**Test C — DIRECTION must match DAILY_CHANGE**
*(Required for all students — targets `fct_daily_stocks`)*
- **Business rule:** A stock marked `UP` must have a positive `DAILY_CHANGE`. `DOWN` must be negative. `FLAT` must be zero. If DIRECTION disagrees with DAILY_CHANGE your CASE statement has a bug.
- **On failure:** Your warehouse fact table logic is inconsistent — trace back to the CASE expression in the model, not the source data
- **File to create:** `tests/test_direction_matches_daily_change.sql`

---

## Running Your Tests

```bash
dbt test                                  # run all tests across all layers
dbt test --select source:snowbearair      # source tests only (RAW layer)
dbt test --select staging                 # staging schema tests only
dbt test --select fct_daily_stocks        # tests on one specific model
dbt test --select test_type:singular      # all singular tests only
```

When a test fails, dbt tells you which model and which test. Your job is not just to make the test pass — it is to understand **why** it failed. Is the source data wrong, or is your model logic wrong? Those require different fixes.

---

## Sprint Requirements Summary

| Sprint | Milestone | Layer | File Location | Test Type | Requirement |
|--------|-----------|-------|--------------|-----------|-------------|
| **S5** | **M4** | RAW | `models/staging/__sources.yml` | Source tests | Pre-configured — review and understand |
| **S5** | **M4** | Staging | `models/staging/staging_tests.yml` | Schema tests | `not_null` + composite/unique key tests on all 3 staging models |
| **S5** | **M5** | Warehouse | `models/warehouse/warehouse_tests.yml` | Schema tests | Grain uniqueness on both fact tables + `accepted_values` on `DIRECTION` + `not_null` on all key columns |
| **S6** | **M6** | DA Mart | `models/marts/marts_tests.yml` | Schema tests | Composite key uniqueness + `not_null` + 1 additional column test |
| **S6** | **M6** | DA Mart | `tests/` folder | Singular SQL | Test A or Test B — whichever matches your DA mart |
| **S6** | **M7** | Warehouse | `tests/` folder | Singular SQL | Test C — required for all students |

**Total meaningful tests across the pipeline: ~10**

Ten tests that you understand and can defend are worth more than thirty you copied without reading.
