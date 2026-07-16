{{
    config(
          materialized='incremental'
        , unique_key='sales_order_detail_key'
        , incremental_strategy='delete+insert'
        , on_schema_change='sync_all_columns'
        , static_analysis='off'
    )
}}

WITH checkout_success_events AS
(
    SELECT
          event_id
        , event_type
        , event_timestamp_utc
        , local_event_timestamp
        , customer_id
        , email_address
        , device_id
        , ip_address
        , store_id
        , order_id
        , raw_event.cart_products                       AS cart_products
        , loaded_at
    FROM {{ ref('stg_glamira__events') }}
    WHERE event_type = 'checkout_success'
      AND order_id IS NOT NULL
      AND raw_event.cart_products IS NOT NULL

    {% if is_incremental() %}

      AND CAST(loaded_at AS TIMESTAMP) >=
          (
              SELECT
                    DATEADD
                    (
                        DAY
                      , -1
                      , COALESCE
                        (
                            MAX
                            (
                                CAST
                                (
                                    target.source_loaded_at
                                    AS TIMESTAMP
                                )
                            )
                          , CAST
                            (
                                '1900-01-01 00:00:00'
                                AS TIMESTAMP
                            )
                        )
                    )
              FROM {{ this }} AS target
          )

    {% endif %}
)

, unnested_products AS
(
    SELECT
          event.event_id
        , event.event_type
        , event.event_timestamp_utc
        , event.local_event_timestamp
        , event.customer_id
        , event.email_address
        , event.device_id
        , event.ip_address
        , event.store_id
        , event.order_id
        , product_item.product_index
        , product_item.product_data
        , event.loaded_at
    FROM checkout_success_events AS event
       , UNNEST(event.cart_products)
         WITH OFFSET AS product_item
         (
               product_data
             , product_index
         )
)

, typed AS
(
    SELECT
          event_id
        , event_type
        , event_timestamp_utc
        , local_event_timestamp
        , customer_id
        , email_address
        , device_id
        , ip_address
        , store_id
        , order_id
        , product_index
        , NULLIF
          (
              TRIM(product_data.product_id::VARCHAR)
            , ''
          )                                             AS product_id
        , TRY_CAST
          (
              NULLIF
              (
                  TRIM(product_data.amount::VARCHAR)
                , ''
              )
              AS INT
          )                                             AS order_qty
        , TRY_CAST
          (
              NULLIF
              (
                  TRIM(product_data.price::VARCHAR)
                , ''
              )
              AS DECIMAL(18, 2)
          )                                             AS unit_price
        , NULLIF
          (
              TRIM(product_data.currency::VARCHAR)
            , ''
          )                                             AS currency_symbol
        , product_data.option                           AS product_options
        , loaded_at                                     AS source_loaded_at
    FROM unnested_products
)

SELECT
      FNV_HASH
      (
          event_id
          || '|'
          || product_index::VARCHAR
      )                                                 AS sales_order_detail_key
    , event_id
    , event_type
    , event_timestamp_utc
    , local_event_timestamp
    , order_id
    , product_index
    , product_id
    , store_id
    , order_qty
    , unit_price
    , CASE
          WHEN order_qty IS NULL
            OR unit_price IS NULL
              THEN NULL
          ELSE order_qty * unit_price
      END                                               AS sales_amount
    , currency_symbol

    -- Raw PII is temporarily retained only for joining.
    , ip_address

    -- Persisted pseudonymous identifiers.
    , {{ hash_pii('customer_id') }}                      AS customer_id_hash
    , {{ hash_pii('email_address') }}                   AS email_address_hash
    , {{ hash_pii('device_id') }}                       AS device_id_hash
    , {{ hash_pii('ip_address') }}                      AS ip_address_hash

    , product_options
    , source_loaded_at
FROM typed