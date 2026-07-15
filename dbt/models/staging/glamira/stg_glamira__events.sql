WITH source_sales AS
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
    FROM {{ ref('int_sales_order_detail__enriched') }}

    {% if is_incremental() %}

    WHERE source_loaded_at >=
          (
              SELECT
                    DATEADD
                    (
                        DAY
                      , -1
                      , COALESCE
                        (
                            MAX(source_loaded_at)
                          , CAST
                            (
                                '1900-01-01 00:00:00'
                                AS TIMESTAMP
                            )
                        )
                    )
              FROM {{ this }}
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
            , CAST
              (
                  order_qty * unit_price
                  AS DECIMAL(18, 2)
              )
          )                                             AS sales_amount
        , NULLIF
          (
              UPPER(TRIM(CAST(currency_code AS VARCHAR(3))))
            , ''
          )                                             AS currency_code
        , COALESCE
          (
              NULLIF(TRIM(customer_country_name), '')
            , 'Unknown'
          )                                             AS customer_country_name
        , COALESCE
          (
              NULLIF(TRIM(customer_region_name), '')
            , 'Unknown'
          )                                             AS customer_region_name
        , COALESCE
          (
              NULLIF(TRIM(customer_city_name), '')
            , 'Unknown'
          )                                             AS customer_city_name
        , customer_identity_hash
        , source_loaded_at
        , ROW_NUMBER() OVER
          (
              PARTITION BY sales_order_detail_key
              ORDER BY
                    source_loaded_at DESC NULLS LAST
                  , event_timestamp_utc DESC NULLS LAST
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