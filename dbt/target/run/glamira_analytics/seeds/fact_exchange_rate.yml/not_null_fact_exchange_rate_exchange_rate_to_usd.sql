
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select exchange_rate_to_usd
from "glamira_analytics"."dbt_brucele16o8_reference"."fact_exchange_rate"
where exchange_rate_to_usd is null



  
  
      
    ) dbt_internal_test