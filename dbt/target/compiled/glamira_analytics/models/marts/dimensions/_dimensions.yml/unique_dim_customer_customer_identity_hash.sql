
    
    

select
    customer_identity_hash as unique_field,
    count(*) as n_records

from "glamira_analytics"."dbt_brucele16o8_mart"."dim_customer"
where customer_identity_hash is not null
group by customer_identity_hash
having count(*) > 1


