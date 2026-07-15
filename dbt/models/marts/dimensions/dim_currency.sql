{{
    config(
        materialized='table'
    )
}}

WITH currencies AS
(
    SELECT DISTINCT
          currency_code
    FROM {{ ref('store_reference') }}
    WHERE currency_code IS NOT NULL
)

SELECT
      -1::BIGINT                  AS currency_key
    , 'UNK'::VARCHAR(20)          AS currency_code

UNION ALL

SELECT
      FNV_HASH(currency_code)     AS currency_key
    , currency_code
FROM currencies