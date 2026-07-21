SELECT
      COUNT(*)                               AS total_rows
    , SUM(sales_amount_usd)                  AS total_sales_usd
FROM dbt_brucele16o8_mart.fact_sales_order_detail