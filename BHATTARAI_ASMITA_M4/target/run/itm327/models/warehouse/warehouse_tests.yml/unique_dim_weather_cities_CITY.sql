select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    CITY as unique_field,
    count(*) as n_records

from PROJECT_DB.MODELED.dim_weather_cities_BHATTARAI_A
where CITY is not null
group by CITY
having count(*) > 1



      
    ) dbt_internal_test