





with validation_errors as (

    select
        symbol, trade_date
    from PROJECT_DB.STAGING.raw_stocks_BHATTARAI_A
    group by symbol, trade_date
    having count(*) > 1

)

select *
from validation_errors


