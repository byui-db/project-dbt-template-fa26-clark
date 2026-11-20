
    
    

select
    id as unique_field,
    count(*) as n_records

from PROJECT_DB.MODELED.raw_news_BHATTARAI_A
where id is not null
group by id
having count(*) > 1


