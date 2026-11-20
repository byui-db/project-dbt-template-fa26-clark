select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select VOLUME
from PROJECT_DB.RAW.MONGO_STOCK_BHATTARAI_A
where VOLUME is null



      
    ) dbt_internal_test