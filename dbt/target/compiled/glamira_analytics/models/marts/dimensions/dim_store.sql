

WITH store_reference AS
(
    SELECT
          CAST(store_id AS VARCHAR(50))           AS store_id
        , CAST(store_domain AS VARCHAR(255))      AS store_domain
        , CAST(store_name AS VARCHAR(255))        AS store_name
        , CAST(country_code AS VARCHAR(2))        AS country_code
        , CAST(country_name AS VARCHAR(255))      AS country_name
        , CAST(currency_code AS VARCHAR(3))       AS currency_code
    FROM "glamira_analytics"."dbt_brucele16o8_reference"."store_reference"
    WHERE store_id IS NOT NULL
)

SELECT
      CAST(-1 AS BIGINT)               AS store_key
    , CAST('Unknown' AS VARCHAR(50))   AS store_id
    , CAST('Unknown' AS VARCHAR(255))  AS store_domain
    , CAST('Unknown' AS VARCHAR(255))  AS store_name
    , CAST('ZZ' AS VARCHAR(2))         AS country_code
    , CAST('Unknown' AS VARCHAR(255))  AS country_name
    , CAST('UNK' AS VARCHAR(3))        AS currency_code

UNION ALL

SELECT
      FNV_HASH(store_id)               AS store_key
    , store_id
    , store_domain
    , store_name
    , country_code
    , country_name
    , currency_code
FROM store_reference