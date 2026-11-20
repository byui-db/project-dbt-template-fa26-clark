# Warehouse Layer — The Dimensional Model

## What the Warehouse Is

The warehouse is where raw cleaned data becomes structured analytics. Your staging layer fixed *quality* — types, nulls, duplicates. The warehouse fixes *shape* — transforming flat source rows into a star schema that marts can query efficiently.

Every model here lands in the **shared** `MODELED` schema, tagged with your `student_prefix`
(e.g. `DIM_NEWS_SMITHJ`) so it doesn't overwrite a classmate's. See *Customize Your Table
Names* in the root README:

```bash
dbt run --target prod          # build all warehouse models
dbt run --target prod --select dim_date   # build one model
```

---

## The Six Models

```
MODELED schema
│
├── dim_date            ← generated calendar dimension (backbone)
├── dim_symbols         ← one row per stock ticker
├── dim_weather_cities  ← one row per financial hub city
├── dim_news            ← one row per news article
│
├── fct_daily_stocks    ← one row per symbol per trading day
└── fct_daily_weather   ← one row per city per day
```

---

## How They Connect

```
dim_date ──────────────────────── DATE_KEY
                                      │
dim_symbols ──── SYMBOL ──── fct_daily_stocks ──── TRADE_DATE
                                      │
dim_news ─────── SYMBOL               │
             └── DATE_KEY ────────────┘

dim_weather_cities ── CITY ──── fct_daily_weather ──── DATE
```

`dim_date` is the backbone — every model with a date column can join through it. Your marts use this to filter by month, quarter, or year without embedding date logic in every mart query.

---

## Build Order

dbt resolves build order automatically through `{{ ref() }}` dependencies. However, understanding the logical order helps you debug:

1. `dim_date` — no dependencies, generate first
2. `dim_symbols`, `dim_weather_cities`, `dim_news` — depend on staging only
3. `fct_daily_stocks`, `fct_daily_weather` — depend on staging only

All six models are independent of each other at the warehouse layer. Joins between them happen in the **mart layer**, not here.

---

## Key Architectural Decision — Why dim_news Is a Dimension

News articles are rich with descriptive string attributes (headline, category, source, summary) and have almost no numeric measures. That makes them **dimension data**, not fact data.

`dim_news` stores one clean row per article. The aggregation of news up to `SYMBOL + DATE` grain happens in the mart layer — different marts may aggregate news differently. A dimension table does not pre-decide how its data will be consumed.

There is no `fct_daily_news`. See `dim_news.sql` for the full explanation.

---

## Schema Tests

Create `models/warehouse/warehouse_tests.yml` to validate your warehouse models. See `tests/README.md` for the full breakdown of test types and what to write here.

Key tests for this layer:
- `not_null` on all primary and foreign key columns
- `unique` or `dbt_utils.unique_combination_of_columns` on every model's grain
- `accepted_values` on `DIRECTION` in `fct_daily_stocks`

---

## Star Schema vs Snowflake Schema — Know the Difference

This project uses a **star schema** — the most common structure for teaching and for smaller analytics workloads. Understanding when and why it evolves into a **snowflake schema** is an important data engineering concept.

### Star Schema (what you are building)

Fact tables sit at the center. Dimension tables connect directly to them. Dimensions are **denormalized** — all attributes for an entity live in one flat table.

```
fct_daily_stocks ──── dim_symbols       (all symbol attributes in one table)
                 ──── dim_date
fct_daily_weather ─── dim_weather_cities (all city attributes in one table)
                 ──── dim_date
```

**Advantages:** Fewer joins, simpler queries, faster for BI tools and analysts.

### Snowflake Schema (how it evolves)

A dimension "snowflakes" when one of its attributes has its **own attributes** worth tracking separately — creating a dimension of a dimension.

**Example:** `dim_symbols` currently has a hypothetical `SECTOR` column. If you wanted to track sector-level statistics (average volatility by sector, number of symbols per sector), `SECTOR` becomes its own table:

```
fct_daily_stocks ──── dim_symbols ──── dim_sectors
                                  └─── dim_exchanges
```

Now `dim_symbols` references `dim_sectors` — the schema has "snowflaked."

**In this project**, a snowflake structure would naturally emerge if you added:
- `dim_news_sources` — one row per publisher, referenced by `dim_news`
- `dim_news_categories` — one row per category, referenced by `dim_news`
- `dim_exchanges` — one row per stock exchange, referenced by `dim_symbols`

### When to Snowflake

Ask this question about any dimension attribute: *"Does this attribute have attributes of its own that I need to analyze?"*

| Scenario | Keep Star | Snowflake |
|----------|-----------|-----------|
| SECTOR is just a label on dim_symbols | ✓ | |
| SECTOR needs its own stats (avg volatility, count of symbols) | | ✓ |
| SOURCE is just a string on dim_news | ✓ | |
| SOURCE needs publisher-level metrics (avg sentiment, article count) | | ✓ |

For this course your star schema is the right choice — it keeps queries simple, is faster to build, and is what most entry-level data engineers will work with. But recognizing when a dimension is ready to split is the judgment call that separates a thoughtful DW designer from someone just following a template.

---

## The Contract This Layer Makes to Marts

> "Every model in this layer has correct grain, clean keys, and pre-calculated metrics. Marts do not need to re-derive, re-clean, or re-aggregate what is already here."

If a mart is doing work the warehouse should have done, the logic belongs here instead.
