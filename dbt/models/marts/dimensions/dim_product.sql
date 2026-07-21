{{
    config(
        materialized='table'
    )
}}

WITH ranked_products AS
(
    SELECT
          product_id
        , sku
        , product_name
        , category_name
        , is_active
        , source_scraped_at
        , source_loaded_at
        , ROW_NUMBER() OVER
          (
              PARTITION BY product_id
              ORDER BY
                    source_scraped_at DESC NULLS LAST
                  , source_loaded_at DESC NULLS LAST
          )                                             AS row_number
    FROM {{ ref('stg_glamira__product_information') }}
    WHERE product_id IS NOT NULL
)

, latest_products AS
(
    SELECT
          product_id
        , COALESCE(sku, 'Unknown SKU')                  AS sku
        , COALESCE
          (
              product_name
            , 'Unknown Product Name'
          )                                             AS product_name
        , COALESCE
          (
              category_name
            , 'Unknown Category'
          )                                             AS category_name
        , is_active
        , source_scraped_at
    FROM ranked_products
    WHERE row_number = 1
)

SELECT
      CAST(-1 AS BIGINT)                                AS product_key
    , CAST('Unknown Product ID' AS VARCHAR(50))         AS product_id
    , CAST('Unknown SKU' AS VARCHAR(255))               AS sku
    , CAST
      (
          'Unknown Product Name'
          AS VARCHAR(1024)
      )                                                 AS product_name
    , CAST
      (
          'Unknown Category'
          AS VARCHAR(512)
      )                                                 AS category_name
    , CAST(NULL AS BOOLEAN)                             AS is_active
    , CAST(NULL AS TIMESTAMPTZ)                         AS source_scraped_at

UNION ALL

SELECT
      FNV_HASH(product_id)                              AS product_key
    , product_id
    , sku
    , product_name
    , category_name
    , is_active
    , source_scraped_at
FROM latest_products