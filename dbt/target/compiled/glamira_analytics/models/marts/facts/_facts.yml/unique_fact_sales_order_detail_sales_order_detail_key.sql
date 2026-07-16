
    
    

select
    sales_order_detail_key as unique_field,
    count(*) as n_records

from "glamira_analytics"."dbt_brucele16o8_mart"."fact_sales_order_detail"
where sales_order_detail_key is not null
group by sales_order_detail_key
having count(*) > 1


