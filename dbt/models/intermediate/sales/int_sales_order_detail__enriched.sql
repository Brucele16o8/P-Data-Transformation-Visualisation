{{
    config(
        materialized='view'
    )
}}

WITH int_sales_order_detail__enriched__source AS
(
    SELECT
          sales_order_detail_key
        , event_id
        , event_timestamp_utc
        , local_event_timestamp
        , order_id
        , product_index
        , product_id
        , store_id
        , order_qty
        , unit_price
        , sales_amount
        , currency_symbol
        , ip_address
        , customer_id_hash
        , email_address_hash
        , device_id_hash
        , ip_address_hash
        , source_loaded_at
    FROM {{ ref('int_checkout_success__order_lines') }}
)

, int_sales_order_detail__enriched__enrich AS
(
    SELECT
          order_lines.sales_order_detail_key
        , order_lines.event_id
        , order_lines.event_timestamp_utc
        , order_lines.local_event_timestamp
        , CAST
          (
              order_lines.event_timestamp_utc
              AS DATE
          )                                             AS sales_date
        , order_lines.order_id
        , order_lines.product_index
        , order_lines.product_id
        , order_lines.store_id
        , order_lines.order_qty
        , order_lines.unit_price
        , order_lines.sales_amount
        , order_lines.currency_symbol

        , store.currency_code
        , store.store_domain
        , store.store_name
        , store.country_code                            AS store_country_code
        , store.country_name                            AS store_country_name

        , COALESCE
          (
              location.country_name
            , 'Unknown'
          )                                             AS customer_country_name
        , COALESCE
          (
              location.region_name
            , 'Unknown'
          )                                             AS customer_region_name
        , COALESCE
          (
              location.city_name
            , 'Unknown'
          )                                             AS customer_city_name

        , COALESCE
          (
                order_lines.customer_id_hash
              , order_lines.email_address_hash
              , order_lines.device_id_hash
          )                                             AS customer_identity_hash

        , order_lines.customer_id_hash
        , order_lines.email_address_hash
        , order_lines.device_id_hash
        , order_lines.ip_address_hash
        , order_lines.source_loaded_at
    FROM int_sales_order_detail__enriched__source AS order_lines
    LEFT JOIN {{ ref('stg_ip_location_lookup') }} AS location
        ON order_lines.ip_address = location.ip_address
    LEFT JOIN {{ ref('store_reference') }} AS store
        ON order_lines.store_id = store.store_id
)
, int_sales_order_detail__enriched__final AS
(
    SELECT
        sales_order_detail_key
        , event_id
        , event_timestamp_utc
        , local_event_timestamp
        , sales_date
        , order_id
        , product_index
        , product_id
        , store_id
        , order_qty
        , unit_price
        , sales_amount
        , currency_symbol
        , currency_code
        , store_domain
        , store_name
        , store_country_code
        , store_country_name
        , customer_country_name
        , customer_region_name
        , customer_city_name
        , customer_identity_hash
        , customer_id_hash
        , email_address_hash
        , device_id_hash
        , ip_address_hash
        , source_loaded_at
    FROM int_sales_order_detail__enriched__enrich
)

SELECT *
FROM int_sales_order_detail__enriched__final