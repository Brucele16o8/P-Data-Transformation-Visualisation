{{
    config(
          materialized='incremental'
        , unique_key='sales_order_detail_key'
        , incremental_strategy='delete+insert'
        , on_schema_change='sync_all_columns'
    )
}}

WITH source_sales AS
(
    SELECT
          source_data.sales_order_detail_key
        , source_data.event_id
        , source_data.event_timestamp_utc
        , source_data.local_event_timestamp
        , source_data.sales_date
        , source_data.order_id
        , source_data.product_id
        , source_data.store_id
        , source_data.order_qty
        , source_data.unit_price
        , source_data.sales_amount
        , source_data.currency_code
        , source_data.customer_country_name
        , source_data.customer_region_name
        , source_data.customer_city_name
        , source_data.customer_identity_hash
        , source_data.source_loaded_at
    FROM {{ ref('int_sales_order_detail__enriched') }} AS source_data

    {% if is_incremental() %}

    WHERE CAST(source_data.source_loaded_at AS TIMESTAMP) >=
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

, prepared_sales AS
(
    SELECT
          sales_order_detail_key
        , event_id
        , event_timestamp_utc
        , local_event_timestamp
        , CAST(sales_date AS DATE)                       AS sales_date
        , order_id
        , NULLIF
          (
              TRIM(CAST(product_id AS VARCHAR(50)))
            , ''
          )                                             AS product_id
        , NULLIF
          (
              TRIM(CAST(store_id AS VARCHAR(50)))
            , ''
          )                                             AS store_id
        , CAST(order_qty AS INTEGER)                     AS order_qty
        , CAST(unit_price AS DECIMAL(18, 2))             AS unit_price
        , COALESCE
          (
              CAST(sales_amount AS DECIMAL(18, 2))
            , CAST(order_qty AS DECIMAL(18, 2))
              * CAST(unit_price AS DECIMAL(18, 2))
          )                                             AS sales_amount
        , NULLIF
          (
              UPPER(TRIM(CAST(currency_code AS VARCHAR(3))))
            , ''
          )                                             AS currency_code
        , CASE
              WHEN customer_country_name IS NULL
                OR TRIM(customer_country_name) = ''
                OR LOWER(TRIM(customer_country_name)) = 'none'
                  THEN 'Unknown'
              ELSE TRIM(customer_country_name)
          END                                           AS customer_country_name
        , CASE
              WHEN customer_region_name IS NULL
                OR TRIM(customer_region_name) = ''
                OR LOWER(TRIM(customer_region_name)) = 'none'
                  THEN 'Unknown'
              ELSE TRIM(customer_region_name)
          END                                           AS customer_region_name
        , CASE
              WHEN customer_city_name IS NULL
                OR TRIM(customer_city_name) = ''
                OR LOWER(TRIM(customer_city_name)) = 'none'
                  THEN 'Unknown'
              ELSE TRIM(customer_city_name)
          END                                           AS customer_city_name
        , customer_identity_hash
        , source_loaded_at
        , ROW_NUMBER() OVER
          (
              PARTITION BY sales_order_detail_key
              ORDER BY
                    source_loaded_at DESC NULLS LAST
                  , event_timestamp_utc DESC NULLS LAST
                  , event_id DESC
          )                                             AS row_number
    FROM source_sales
)

, sales AS
(
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
        , currency_code
        , customer_country_name
        , customer_region_name
        , customer_city_name
        , customer_identity_hash
        , source_loaded_at
    FROM prepared_sales
    WHERE row_number = 1
      AND sales_amount IS NOT NULL
)

SELECT
      sales.sales_order_detail_key
    , COALESCE
      (
          customer.customer_key
        , CAST(-1 AS BIGINT)
      )                                                 AS customer_key
    , COALESCE
      (
          store.store_key
        , CAST(-1 AS BIGINT)
      )                                                 AS store_key
    , COALESCE
      (
          date_dimension.date_key
        , CAST(-1 AS INTEGER)
      )                                                 AS date_key
    , COALESCE
      (
          product.product_key
        , CAST(-1 AS BIGINT)
      )                                                 AS product_key
    , COALESCE
      (
          location.location_key
        , CAST(-1 AS BIGINT)
      )                                                 AS location_key
    , COALESCE
      (
          currency.currency_key
        , CAST(-1 AS BIGINT)
      )                                                 AS currency_key
    , sales.event_id
    , sales.order_id
    , sales.product_id                                  AS source_product_id
    , sales.store_id                                    AS source_store_id
    , sales.event_timestamp_utc
    , sales.local_event_timestamp
    , sales.order_qty
    , sales.unit_price
    , sales.sales_amount
    , sales.currency_code                               AS source_currency_code
    , exchange_rate.exchange_rate_to_usd
    , CASE
          WHEN exchange_rate.exchange_rate_to_usd IS NULL
              THEN NULL
          ELSE CAST
               (
                   ROUND
                   (
                       sales.sales_amount
                       * exchange_rate.exchange_rate_to_usd
                     , 2
                   )
                   AS DECIMAL(18, 2)
               )
      END                                               AS sales_amount_usd
    , CAST('USD' AS VARCHAR(3))                         AS reporting_currency_code
    , sales.source_loaded_at
FROM sales
LEFT JOIN {{ ref('dim_customer') }} AS customer
    ON sales.customer_identity_hash
       = customer.customer_identity_hash
LEFT JOIN {{ ref('dim_store') }} AS store
    ON sales.store_id = store.store_id
LEFT JOIN {{ ref('dim_date') }} AS date_dimension
    ON sales.sales_date = date_dimension.full_date
LEFT JOIN {{ ref('dim_product') }} AS product
    ON sales.product_id = product.product_id
LEFT JOIN {{ ref('dim_location') }} AS location
    ON sales.customer_country_name = location.country_name
   AND sales.customer_region_name = location.region_name
   AND sales.customer_city_name = location.city_name
LEFT JOIN {{ ref('dim_currency') }} AS currency
    ON sales.currency_code = currency.currency_code
LEFT JOIN {{ ref('exchange_rate') }} AS exchange_rate
    ON sales.currency_code = exchange_rate.currency_code