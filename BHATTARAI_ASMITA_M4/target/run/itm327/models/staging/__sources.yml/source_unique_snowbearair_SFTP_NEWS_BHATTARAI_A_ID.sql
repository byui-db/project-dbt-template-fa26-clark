select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    ID as unique_field,
    count(*) as n_records

from PROJECT_DB.RAW.SFTP_NEWS_BHATTARAI_A
where ID is not null
group by ID
having count(*) > 1



      
    ) dbt_internal_test