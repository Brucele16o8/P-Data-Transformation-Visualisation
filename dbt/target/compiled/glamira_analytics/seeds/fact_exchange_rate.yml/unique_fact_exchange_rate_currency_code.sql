
    
    

select
    currency_code as unique_field,
    count(*) as n_records

from "glamira_analytics"."dbt_brucele16o8_reference"."fact_exchange_rate"
where currency_code is not null
group by currency_code
having count(*) > 1


