select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select CITY
from PROJECT_DB.RAW.API_WEATHER_BHATTARAI_A
where CITY is null



      
    ) dbt_internal_test