select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select SYMBOL
from PROJECT_DB.MODELED.fct_daily_stocks_BHATTARAI_A
where SYMBOL is null



      
    ) dbt_internal_test