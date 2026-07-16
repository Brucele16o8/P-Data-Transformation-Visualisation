

WITH cleaned_locations AS
(
    SELECT
          CASE
              WHEN country IS NULL
                OR TRIM(country) = ''
                OR LOWER(TRIM(country)) = 'none'
                  THEN 'Unknown'
              ELSE TRIM(country)
          END                                           AS country_name
        , CASE
              WHEN region IS NULL
                OR TRIM(region) = ''
                OR LOWER(TRIM(region)) = 'none'
                  THEN 'Unknown'
              ELSE TRIM(region)
          END                                           AS region_name
        , CASE
              WHEN city IS NULL
                OR TRIM(city) = ''
                OR LOWER(TRIM(city)) = 'none'
                  THEN 'Unknown'
              ELSE TRIM(city)
          END                                           AS city_name
    FROM "glamira_analytics"."landing"."ip_location_lookup"
)

, distinct_locations AS
(
    SELECT DISTINCT
          CAST(country_name AS VARCHAR(255))             AS country_name
        , CAST(region_name AS VARCHAR(255))              AS region_name
        , CAST(city_name AS VARCHAR(255))                AS city_name
    FROM cleaned_locations
    WHERE NOT
    (
            country_name = 'Unknown'
        AND region_name = 'Unknown'
        AND city_name = 'Unknown'
    )
)

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
FROM distinct_locations