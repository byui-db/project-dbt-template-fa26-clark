select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select PUBLISHED_AT
from PROJECT_DB.RAW.SFTP_NEWS_BHATTARAI_A
where PUBLISHED_AT is null



      
    ) dbt_internal_test