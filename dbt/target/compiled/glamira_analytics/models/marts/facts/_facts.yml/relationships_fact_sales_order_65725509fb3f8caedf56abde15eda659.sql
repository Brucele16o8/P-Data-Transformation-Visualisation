
    
    

with child as (
    select product_key as from_field
    from "glamira_analytics"."dbt_brucele16o8_mart"."fact_sales_order_detail"
    where product_key is not null
),

parent as (
    select product_key as to_field
    from "glamira_analytics"."dbt_brucele16o8_mart"."dim_product"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


