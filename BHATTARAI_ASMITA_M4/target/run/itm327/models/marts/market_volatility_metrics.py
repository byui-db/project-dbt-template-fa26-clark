
  
    
    
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


# This part is user provided model code
# you will need to copy the next section to run the code
# COMMAND ----------
# this part is dbt logic for get ref work, do not modify

def ref(*args, **kwargs):
    refs = {}
    key = '.'.join(args)
    version = kwargs.get("v") or kwargs.get("version")
    if version:
        key += f".v{version}"
    dbt_load_df_function = kwargs.get("dbt_load_df_function")
    return dbt_load_df_function(refs[key])


def source(*args, dbt_load_df_function):
    sources = {}
    key = '.'.join(args)
    return dbt_load_df_function(sources[key])


config_dict = {}


class config:
    def __init__(self, *args, **kwargs):
        pass

    @staticmethod
    def get(key, default=None):
        return config_dict.get(key, default)

class this:
    """dbt.this() or dbt.this.identifier"""
    database = "PROJECT_DB"
    schema = "STAGING"
    identifier = "market_volatility_metrics_BHATTARAI_A"
    
    def __repr__(self):
        return 'PROJECT_DB.STAGING.market_volatility_metrics_BHATTARAI_A'


class dbtObj:
    def __init__(self, load_df_function) -> None:
        self.source = lambda *args: source(*args, dbt_load_df_function=load_df_function)
        self.ref = lambda *args, **kwargs: ref(*args, **kwargs, dbt_load_df_function=load_df_function)
        self.config = config
        self.this = this()
        self.is_incremental = False

# COMMAND ----------



def materialize(session, df, target_relation):
    # make sure pandas exists
    import importlib.util
    package_name = 'pandas'
    if importlib.util.find_spec(package_name):
        import pandas
        if isinstance(df, pandas.core.frame.DataFrame):
          session.use_database(target_relation.database)
          session.use_schema(target_relation.schema)
          # session.write_pandas does not have overwrite function
          df = session.createDataFrame(df)
    
    df.write.mode("overwrite").save_as_table('PROJECT_DB.STAGING.market_volatility_metrics_BHATTARAI_A', table_type='transient')

def main(session):
    dbt = dbtObj(session.table)
    df = model(dbt, session)
    materialize(session, df, dbt.this)
    return "OK"

  