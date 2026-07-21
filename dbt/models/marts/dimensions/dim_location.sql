{{
    config(
        materialized='table'
    )
}}

WITH dim_location__distinct_locations AS
(
    SELECT DISTINCT
          CAST(country_name AS VARCHAR(255))             AS country_name
        , CAST(region_name AS VARCHAR(255))              AS region_name
        , CAST(city_name AS VARCHAR(255))                AS city_name
    FROM {{ ref('stg_ip_location_lookup') }}
    WHERE NOT
    (
            country_name = 'Unknown'
        AND region_name = 'Unknown'
        AND city_name = 'Unknown'
    )
)
, dim_location__final AS 
(
    SELECT
          CAST(-1 AS BIGINT)                                AS location_key
        , CAST('Unknown' AS VARCHAR(255))                   AS country_name
        , CAST('Unknown' AS VARCHAR(255))                   AS region_name
        , CAST('Unknown' AS VARCHAR(255))                   AS city_name

    UNION ALL

    SELECT
        FNV_HASH
        (
                country_name
                || '|'
                || region_name
                || '|'
                || city_name
        )                                                 AS location_key
        , country_name
        , region_name
        , city_name
    FROM dim_location__distinct_locations
)

SELECT *
FROM dim_location__final