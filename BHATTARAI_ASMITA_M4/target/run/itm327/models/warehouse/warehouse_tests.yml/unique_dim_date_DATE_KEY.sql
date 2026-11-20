select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    DATE_KEY as unique_field,
    count(*) as n_records

from PROJECT_DB.MODELED.dim_date_BHATTARAI_A
where DATE_KEY is not null
group by DATE_KEY
having count(*) > 1



      
    ) dbt_internal_test