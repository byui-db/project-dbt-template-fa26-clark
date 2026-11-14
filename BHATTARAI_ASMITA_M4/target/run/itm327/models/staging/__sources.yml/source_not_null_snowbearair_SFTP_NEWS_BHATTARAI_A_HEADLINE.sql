select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select HEADLINE
from PROJECT_DB.RAW.SFTP_NEWS_BHATTARAI_A
where HEADLINE is null



      
    ) dbt_internal_test