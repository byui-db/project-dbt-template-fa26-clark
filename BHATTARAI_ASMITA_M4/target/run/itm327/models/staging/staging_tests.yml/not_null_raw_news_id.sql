select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select id
from PROJECT_DB.STAGING.raw_news_BHATTARAI_A
where id is null



      
    ) dbt_internal_test