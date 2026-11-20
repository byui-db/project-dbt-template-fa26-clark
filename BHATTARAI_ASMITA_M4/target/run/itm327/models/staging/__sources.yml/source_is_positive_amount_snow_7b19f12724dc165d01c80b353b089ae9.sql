select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

select *
from PROJECT_DB.RAW.MONGO_STOCK_BHATTARAI_A
where CLOSE is not null and CLOSE <= 0


      
    ) dbt_internal_test