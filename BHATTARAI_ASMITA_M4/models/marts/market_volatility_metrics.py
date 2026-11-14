# ============================================================
# market_volatility_metrics
# DS Mart: per-symbol statistical features for risk modeling
# Grain: SYMBOL (one row per stock ticker)
# Source: dbt.ref('fct_daily_stocks')
# Client: Data Scientist — ML feature store input
# ============================================================
#
# This mart answers: "Which stocks are most volatile, which
# direction do they trend, and what does news sentiment tell
# us about how the market perceives them?"
#
# Unlike SQL marts, this model uses Snowpark DataFrames.
# It receives a dbt session and must return a Snowpark DataFrame.
# dbt materializes the returned DataFrame as a table.
#
# COLUMNS TO BUILD:
#
#   Key:
#     SYMBOL
#
#   Trading activity:
#     TRADING_DAYS          — count of days in your dataset
#     FIRST_TRADE_DATE      — earliest date for this symbol
#     LAST_TRADE_DATE       — latest date for this symbol
#
#   Price range:
#     PERIOD_HIGH           — highest HIGH across all history
#     PERIOD_LOW            — lowest LOW across all history
#     AVG_CLOSE             — average closing price
#
#   Volume:
#     AVG_DAILY_VOLUME      — average daily volume
#     TOTAL_VOLUME          — total volume across all history
#
#   Statistical features (what makes this a DS mart):
#     AVG_DAILY_RANGE       — average intraday range (HIGH - LOW)
#     RETURN_VOLATILITY     — standard deviation of daily return %
#                             higher = more unpredictable stock
#     AVG_DAILY_RETURN_PCT  — average daily return %
#
#   Direction counts:
#     UP_DAYS               — days where DAILY_CHANGE > 0
#     DOWN_DAYS             — days where DAILY_CHANGE < 0
#
#   Sentiment (Cortex AI):
#     SENTIMENT_SCORE       — average news sentiment for this symbol
#                             computed by SNOWFLAKE.CORTEX.SENTIMENT()
#                             on aggregated headlines from dim_news
#                             range: -1 (negative) to 1 (positive)
#
# SNOWPARK HINT:
#   Reference warehouse models with dbt.ref() — the Python equivalent of
#   the ref() function you use in SQL models. (Jinja tag syntax is NOT
#   allowed anywhere in a Python model, even in comments — use dbt.ref().)
#
#     stocks_df = dbt.ref('fct_daily_stocks')
#
#   Use .groupBy('SYMBOL').agg(...) to compute per-symbol stats.
#   Import aggregation functions from snowflake.snowpark.functions.
#
# CORTEX HINT:
#   SNOWFLAKE.CORTEX.SENTIMENT() is a SQL function. You can call
#   it from Python using session.sql() — Python and SQL work
#   together inside Snowflake. Aggregate dim_news headlines to
#   SYMBOL grain first, then apply the sentiment function.
#
# ============================================================

from snowflake.snowpark.functions import col, avg, stddev, count
from snowflake.snowpark.functions import max as max_, min as min_
from snowflake.snowpark.functions import sum as sum_, when, lit


def model(dbt, session):
    # TODO: Reference your warehouse models via dbt.ref()
    # TODO: Compute derived columns before aggregation
    # TODO: Aggregate per symbol using .groupBy().agg()
    # TODO: Join Cortex sentiment scores via session.sql()
    # TODO: Return the final Snowpark DataFrame
    # Placeholder so the template compiles; REPLACE this return with your own DataFrame.
    return session.sql("select 1 as placeholder")
