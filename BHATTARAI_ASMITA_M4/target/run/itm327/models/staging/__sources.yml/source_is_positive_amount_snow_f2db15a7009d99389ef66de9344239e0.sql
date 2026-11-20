select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

select *
from PROJECT_DB.RAW.MONGO_STOCK_BHATTARAI_A
where VOLUME is not null and VOLUME <= 0


      
    ) dbt_internal_test