{{
    config(
        materialized='table'
    )
}}

WITH source_data AS
(
    SELECT
          NULLIF
          (
              TRIM(CAST(product_id AS VARCHAR(50)))
            , ''
          )                                             AS product_id
        , NULLIF
          (
              TRIM(CAST(sku AS VARCHAR(255)))
            , ''
          )                                             AS sku
        , COALESCE
          (
              NULLIF
              (
                  TRIM(CAST(product_name AS VARCHAR(1024)))
                , ''
              )
            , NULLIF
              (
                  TRIM(CAST(name AS VARCHAR(1024)))
                , ''
              )
          )                                             AS product_name
        , COALESCE
          (
              NULLIF
              (
                  TRIM(CAST(category_name AS VARCHAR(512)))
                , ''
              )
            , NULLIF
              (
                  TRIM(CAST(category AS VARCHAR(512)))
                , ''
              )
          )                                             AS category_name
        , CAST(active AS BOOLEAN)                       AS is_active
        , CAST(scraped_at AS TIMESTAMPTZ)               AS source_scraped_at
        , loaded_at
    FROM {{ source('landing', 'product_information') }}
    WHERE NULLIF
          (
              TRIM(CAST(product_id AS VARCHAR(50)))
            , ''
          ) IS NOT NULL
)

, ranked_products AS
(
    SELECT
          product_id
        , sku
        , product_name
        , category_name
        , is_active
        , source_scraped_at
        , ROW_NUMBER() OVER
          (
              PARTITION BY product_id
              ORDER BY
                    source_scraped_at DESC NULLS LAST
                  , loaded_at DESC NULLS LAST
          )                                             AS row_number
    FROM source_data
)

, latest_products AS
(
    SELECT
          product_id
        , COALESCE(sku, 'Unknown')                      AS sku
        , COALESCE(product_name, 'Unknown')             AS product_name
        , COALESCE(category_name, 'Unknown')            AS category_name
        , is_active
        , source_scraped_at
    FROM ranked_products
    WHERE row_number = 1
)

SELECT
      CAST(-1 AS BIGINT)                AS product_key
    , CAST('Unknown' AS VARCHAR(50))    AS product_id
    , CAST('Unknown' AS VARCHAR(255))   AS sku
    , CAST('Unknown' AS VARCHAR(1024))  AS product_name
    , CAST('Unknown' AS VARCHAR(512))   AS category_name
    , CAST(NULL AS BOOLEAN)             AS is_active
    , CAST(NULL AS TIMESTAMPTZ)         AS source_scraped_at

UNION ALL

SELECT
      FNV_HASH(product_id)              AS product_key
    , product_id
    , sku
    , product_name
    , category_name
    , is_active
    , source_scraped_at
FROM latest_products