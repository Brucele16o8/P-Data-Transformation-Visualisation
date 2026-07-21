{{
    config(
        materialized='table'
    )
}}

WITH dim_currency__currencies AS
(
    SELECT DISTINCT
          currency_code
    FROM {{ ref('store_reference') }}
    WHERE currency_code IS NOT NULL
)
, dim_currency__final AS 
(
    SELECT
        -1::BIGINT                  AS currency_key
        , 'UNK'::VARCHAR(20)          AS currency_code

    UNION ALL

    SELECT
        FNV_HASH(currency_code)     AS currency_key
        , currency_code
    FROM dim_currency__currencies
)

SELECT *
FROM dim_currency__final
