{{
    config(
        materialized='table'
    )
}}

WITH ranked_customers AS
(
    SELECT
          customer_identity_hash
        , customer_id_hash
        , email_address_hash
        , device_id_hash
        , ROW_NUMBER() OVER
          (
              PARTITION BY customer_identity_hash
              ORDER BY
                    source_loaded_at DESC NULLS LAST
                  , event_timestamp_utc DESC NULLS LAST
                  , event_id DESC
          )                                             AS row_number
    FROM {{ ref('int_sales_order_detail__enriched') }}
    WHERE customer_identity_hash IS NOT NULL
)

SELECT
      CAST(-1 AS BIGINT)                                AS customer_key
    , CAST('Unknown' AS VARCHAR(64))                    AS customer_identity_hash
    , CAST(NULL AS VARCHAR(64))                         AS customer_id_hash
    , CAST(NULL AS VARCHAR(64))                         AS email_address_hash
    , CAST(NULL AS VARCHAR(64))                         AS device_id_hash

UNION ALL

SELECT
      FNV_HASH(customer_identity_hash)                  AS customer_key
    , customer_identity_hash
    , customer_id_hash
    , email_address_hash
    , device_id_hash
FROM ranked_customers
WHERE row_number = 1