# ============================================================
# ITM327 | Sprint 7 — Data Mart Dashboard
# Streamlit in Snowflake Template
#
# INSTRUCTIONS:
#   1. In Snowflake, go to Projects > Streamlit > + Streamlit App
#   2. Paste this file into the editor
#   3. Complete every TODO below — use AI to help generate chart code
#   4. You are presenting ONE mart (DA or DS) — delete the other section
#
# YOUR MART OPTIONS:
#   DA Mart — stock_news_daily or weather_market_conditions (SQL model)
#   DS Mart — market_volatility_metrics (Python/Snowpark + Cortex sentiment)
# ============================================================

import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

# --- Connection (do not change) ---
session = get_active_session()

# --- Page Config ---
st.set_page_config(
    page_title="TODO: Your Mart Name",   # TODO: rename
    layout="wide"
)

# ============================================================
# HEADER
# ============================================================
st.title("TODO: Your Dashboard Title")  # TODO: rename

st.caption(
    "Source: Airflow → Snowflake RAW → dbt Staged → dbt Modeled | "
    "Mart: TODO_SCHEMA.TODO_MART_TABLE"  # TODO: fill in schema and mart table name
)

st.divider()

# ============================================================
# LOAD DATA
# ============================================================
@st.cache_data
def load_data():
    # TODO: Replace with your mart table name
    # Pattern: session.table("SCHEMA.TABLE_NAME").to_pandas()
    #
    # DA mart examples:
    #   session.table("DEV.STOCK_NEWS_DAILY").to_pandas()
    #   session.table("DEV.WEATHER_MARKET_CONDITIONS").to_pandas()
    #
    # DS mart example:
    #   session.table("DEV.MARKET_VOLATILITY_METRICS").to_pandas()
    #
    df = session.table("DEV.TODO_YOUR_MART_TABLE").to_pandas()
    return df

df = load_data()

# ============================================================
# SIDEBAR — FILTERS
# ============================================================
st.sidebar.header("Filters")

# TODO: Add one filter relevant to your mart's key dimension
# Examples:
#
#   Stock symbol filter (DA / DS mart):
#     symbols = sorted(df["SYMBOL"].unique())
#     selected = st.sidebar.multiselect("Symbol", symbols, default=symbols[:3])
#     df = df[df["SYMBOL"].isin(selected)]
#
#   Date range filter:
#     min_date = df["TRADE_DATE"].min()
#     max_date = df["TRADE_DATE"].max()
#     start, end = st.sidebar.date_input("Date Range", [min_date, max_date])
#     df = df[(df["TRADE_DATE"] >= str(start)) & (df["TRADE_DATE"] <= str(end))]
#
#   City filter (weather mart):
#     cities = sorted(df["CITY"].unique())
#     selected = st.sidebar.multiselect("City", cities, default=cities)
#     df = df[df["CITY"].isin(selected)]

st.sidebar.info("TODO: Add your filter above and delete this message.")

# ============================================================
# SECTION 1 — SUMMARY METRICS (3 cards)
# ============================================================
st.subheader("Summary")

col1, col2, col3 = st.columns(3)

# TODO: Replace each metric with a meaningful value from your mart
# Examples:
#   col1.metric("Symbols Tracked", df["SYMBOL"].nunique())
#   col2.metric("Avg Daily Return", f"{df['PCT_CHANGE'].mean():.2f}%")
#   col3.metric("Total News Articles", int(df["NEWS_ARTICLE_COUNT"].sum()))

col1.metric("TODO Metric 1", "—")
col2.metric("TODO Metric 2", "—")
col3.metric("TODO Metric 3", "—")

st.divider()

# ============================================================
# SECTION 2 — MAIN CHART
# ============================================================
st.subheader("TODO: Main Chart Title")

# TODO: Replace with a chart that answers your mart's primary business question
# Examples:
#
#   Line chart — stock close price over time (pivot for multi-symbol):
#     pivot = df.pivot(index="TRADE_DATE", columns="SYMBOL", values="CLOSE")
#     st.line_chart(pivot)
#
#   Bar chart — average daily return by symbol:
#     avg_return = df.groupby("SYMBOL")["PCT_CHANGE"].mean().reset_index()
#     st.bar_chart(avg_return, x="SYMBOL", y="PCT_CHANGE")
#
#   Scatter — volatility vs avg return (DS mart):
#     st.scatter_chart(df, x="RETURN_VOLATILITY", y="AVG_DAILY_RETURN_PCT", color="SYMBOL")

st.info("TODO: Add your main chart above and delete this message.")

st.divider()

# ============================================================
# SECTION 3 — SECONDARY CHART
# ============================================================
st.subheader("TODO: Secondary Chart Title")

# TODO: Add a second chart that answers a different question from the same mart
# This could be a breakdown, distribution, or comparison

st.info("TODO: Add your secondary chart above and delete this message.")

st.divider()

# ============================================================
# SECTION 4 — DS MART ONLY: SENTIMENT (pre-computed in dbt)
# ============================================================
# TODO: If you are using the DS mart, uncomment this section.
#       If you are using the DA mart, delete this entire section.
#
# SENTIMENT_SCORE is computed by Snowflake Cortex in your dbt mart model —
# it is already a column in your mart table, not calculated here.

# st.subheader("News Sentiment Analysis")
#
# avg_sentiment = df.groupby("SYMBOL")["SENTIMENT_SCORE"].mean().reset_index()
# st.bar_chart(avg_sentiment, x="SYMBOL", y="SENTIMENT_SCORE")
#
# with st.expander("View Scored Headlines"):
#     st.dataframe(
#         df[["TRADE_DATE", "SYMBOL", "HEADLINE", "SENTIMENT_SCORE"]].sort_values("TRADE_DATE", ascending=False),
#         use_container_width=True
#     )

# ============================================================
# SECTION 5 — RAW DATA TABLE
# ============================================================
with st.expander("View Mart Data"):
    st.caption(f"{len(df):,} rows after filters applied")
    st.dataframe(df, use_container_width=True)

# ============================================================
# FOOTER
# ============================================================
st.divider()
st.caption(
    "ITM327 | BYU-Idaho | "
    "Pipeline: Airflow (Extract + Load) → dbt (Stage + Model) → Streamlit (Present)"
)
