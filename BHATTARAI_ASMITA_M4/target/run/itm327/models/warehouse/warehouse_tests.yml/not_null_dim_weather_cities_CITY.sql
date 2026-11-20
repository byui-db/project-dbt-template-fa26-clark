select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select CITY
from PROJECT_DB.MODELED.dim_weather_cities_BHATTARAI_A
where CITY is null



      
    ) dbt_internal_test