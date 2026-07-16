
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select currency_code
from "glamira_analytics"."dbt_brucele16o8_reference"."fact_exchange_rate"
where currency_code is null



  
  
      
    ) dbt_internal_test