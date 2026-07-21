{{
    config(
        materialized='view'
    )
}}

WITH stg_ip_location_lookup__source AS
(
    SELECT
          ip
        , country
        , region
        , city
        , latitude
        , longitude
        , processed_at
        , status
        , error_message
        , loaded_at
    FROM {{ source('landing', 'ip_location_lookup') }}
)
, stg_ip_location_lookup__clean AS 
(
    SELECT
        NULLIF
        (
            TRIM(CAST(ip AS VARCHAR(50)))
            , ''
        )                                                 AS ip_address
        , CASE
            WHEN country IS NULL
                OR TRIM(CAST(country AS VARCHAR(255))) = ''
                OR LOWER
                (
                    TRIM
                    (
                        CAST(country AS VARCHAR(255))
                    )
                ) = 'none'
                THEN 'Unknown'
            ELSE TRIM(CAST(country AS VARCHAR(255)))
        END                                               AS country_name
        , CASE
            WHEN region IS NULL
                OR TRIM(CAST(region AS VARCHAR(255))) = ''
                OR LOWER
                (
                    TRIM
                    (
                        CAST(region AS VARCHAR(255))
                    )
                ) = 'none'
                THEN 'Unknown'
            ELSE TRIM(CAST(region AS VARCHAR(255)))
        END                                               AS region_name
        , CASE
            WHEN city IS NULL
                OR TRIM(CAST(city AS VARCHAR(255))) = ''
                OR LOWER
                (
                    TRIM
                    (
                        CAST(city AS VARCHAR(255))
                    )
                ) = 'none'
                THEN 'Unknown'
            ELSE TRIM(CAST(city AS VARCHAR(255)))
        END                                               AS city_name
        , TRY_CAST(latitude AS DECIMAL(10, 6))              AS latitude
        , TRY_CAST(longitude AS DECIMAL(10, 6))             AS longitude
        , CAST(processed_at AS TIMESTAMP)                   AS processed_at
        , NULLIF
        (
            TRIM(CAST(status AS VARCHAR(50)))
            , ''
        )                                                 AS status
        , NULLIF
        (
            TRIM(CAST(error_message AS VARCHAR(1000)))
            , ''
        )                                                 AS error_message
        , CAST(loaded_at AS TIMESTAMP)                      AS loaded_at
    FROM stg_ip_location_lookup__source
)
, stg_ip_location_lookup__final AS (
    SELECT
          ip_address
        , country_name
        , region_name
        , city_name
        , latitude
        , longitude
        , processed_at
        , status
        , error_message
        , loaded_at
    FROM stg_ip_location_lookup__clean
)

SELECT *
FROM stg_ip_location_lookup__final