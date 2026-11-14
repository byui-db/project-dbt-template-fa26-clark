select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select trade_date
from PROJECT_DB.STAGING.raw_stocks_BHATTARAI_A
where trade_date is null



      
    ) dbt_internal_test