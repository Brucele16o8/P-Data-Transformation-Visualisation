{{
    config(
        materialized='table'
    )
}}

WITH customers AS
(
    SELECT DISTINCT
          customer_identity_hash
        , customer_id_hash
        , email_address_hash
        , device_id_hash
    FROM {{ ref('int_sales_order_detail__enriched') }}
    WHERE customer_identity_hash IS NOT NULL
)

, unknown_customer AS
(
    SELECT
          -1::BIGINT                AS customer_key
        , 'Unknown'::VARCHAR(64)    AS customer_identity_hash
        , NULL::VARCHAR(64)         AS customer_id_hash
        , NULL::VARCHAR(64)         AS email_address_hash
        , NULL::VARCHAR(64)         AS device_id_hash
)

, known_customers AS
(
    SELECT
          FNV_HASH(customer_identity_hash)  AS customer_key
        , customer_identity_hash
        , customer_id_hash
        , email_address_hash
        , device_id_hash
    FROM customers
)

SELECT
      customer_key
    , customer_identity_hash
    , customer_id_hash
    , email_address_hash
    , device_id_hash
FROM unknown_customer

UNION ALL

SELECT
      customer_key
    , customer_identity_hash
    , customer_id_hash
    , email_address_hash
    , device_id_hash
FROM known_customers