

WITH currencies AS
(
    SELECT DISTINCT
          currency_code
    FROM "glamira_analytics"."dbt_brucele16o8_reference"."store_reference"
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