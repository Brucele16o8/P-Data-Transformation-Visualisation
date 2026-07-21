{{
    config(
        materialized='view'
    )
}}

WITH stg_glamira__product_information__source_product AS
(
    SELECT
          product_id
        , sku
        , product_name
        , name
        , category_name
        , category
        , active
        , scraped_at
        , loaded_at
    FROM {{ source('landing', 'product_information') }}
)
, stg_glamira__product_information__final AS 
(
    SELECT
        NULLIF
        (
            TRIM(CAST(product_id AS VARCHAR(50)))
            , ''
        )                                                 AS product_id
        , NULLIF
        (
            TRIM(CAST(sku AS VARCHAR(255)))
            , ''
        )                                                 AS sku
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
        )                                                 AS product_name
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
        )                                                 AS category_name
        , CAST(active AS BOOLEAN)                           AS is_active
        , CAST(scraped_at AS TIMESTAMPTZ)                   AS source_scraped_at
        , CAST(loaded_at AS TIMESTAMPTZ)                    AS source_loaded_at
    FROM stg_glamira__product_information__source_product    
)

SELECT *
FROM stg_glamira__product_information__final
