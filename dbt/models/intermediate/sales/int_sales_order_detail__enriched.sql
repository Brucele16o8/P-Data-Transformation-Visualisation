{{
    config(
        materialized='view'
    )
}}

WITH order_lines AS
(
    SELECT
          sales_order_detail_key
        , event_id
        , event_timestamp_utc
        , local_event_timestamp
        , order_id
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

, enriched AS
(
    SELECT
          order_lines.sales_order_detail_key
        , order_lines.event_id
        , order_lines.event_timestamp_utc
        , order_lines.local_event_timestamp
        , CAST(order_lines.event_timestamp_utc AS DATE)  AS sales_date
        , order_lines.order_id
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
        , location.country                              AS customer_country_name
        , location.region                               AS customer_region_name
        , NULLIF
          (
              NULLIF(TRIM(location.city), '')
            , 'None'
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
    FROM order_lines
    LEFT JOIN {{ source('landing', 'ip_location_lookup') }} AS location
        ON order_lines.ip_address = location.ip
    LEFT JOIN {{ ref('store_reference') }} AS store
        ON order_lines.store_id = store.store_id
)

SELECT
      sales_order_detail_key
    , event_id
    , event_timestamp_utc
    , local_event_timestamp
    , sales_date
    , order_id
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
FROM enriched