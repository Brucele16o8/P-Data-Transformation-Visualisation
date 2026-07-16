

WITH RECURSIVE date_parameters AS
(
    SELECT
          CAST
          (
              '2018-01-01'
              AS DATE
          )                                             AS start_date
        , CAST
          (
              '2035-12-31'
              AS DATE
          )                                             AS end_date
)

, date_spine
(
      full_date
    , end_date
)
AS
(
    SELECT
          start_date                                    AS full_date
        , end_date
    FROM date_parameters

    UNION ALL

    SELECT
          CAST
          (
              DATEADD
              (
                  DAY
                , 1
                , full_date
              )
              AS DATE
          )                                             AS full_date
        , end_date
    FROM date_spine
    WHERE full_date < end_date
)

, known_dates AS
(
    SELECT
          CAST
          (
              TO_CHAR(full_date, 'YYYYMMDD')
              AS INT
          )                                             AS date_key
        , full_date
        , CAST
          (
              DATE_PART(YEAR, full_date)
              AS SMALLINT
          )                                             AS year_number
        , CAST
          (
              DATE_PART(QUARTER, full_date)
              AS SMALLINT
          )                                             AS quarter_number
        , CAST
          (
              DATE_PART(MONTH, full_date)
              AS SMALLINT
          )                                             AS month_number
        , CAST
          (
              TRIM(TO_CHAR(full_date, 'Month'))
              AS VARCHAR(20)
          )                                             AS month_name
        , CAST
          (
              DATE_PART(WEEK, full_date)
              AS SMALLINT
          )                                             AS week_number
        , CAST
          (
              DATE_PART(DAY, full_date)
              AS SMALLINT
          )                                             AS day_number
        , CAST
          (
              TRIM(TO_CHAR(full_date, 'Day'))
              AS VARCHAR(20)
          )                                             AS day_name
        , CAST
          (
              TO_CHAR(full_date, 'YYYY-MM')
              AS VARCHAR(7)
          )                                             AS year_month
        , CAST
          (
              DATE_TRUNC('month', full_date)
              AS DATE
          )                                             AS month_start_date
        , CAST
          (
              DATE_TRUNC('quarter', full_date)
              AS DATE
          )                                             AS quarter_start_date
        , CASE
              WHEN DATE_PART(DOW, full_date) IN (0, 6)
                  THEN TRUE
              ELSE FALSE
          END                                           AS is_weekend
    FROM date_spine
)

SELECT
      CAST(-1 AS INT)                                   AS date_key
    , CAST(NULL AS DATE)                                AS full_date
    , CAST(NULL AS SMALLINT)                            AS year_number
    , CAST(NULL AS SMALLINT)                            AS quarter_number
    , CAST(NULL AS SMALLINT)                            AS month_number
    , CAST('Unknown' AS VARCHAR(20))                    AS month_name
    , CAST(NULL AS SMALLINT)                            AS week_number
    , CAST(NULL AS SMALLINT)                            AS day_number
    , CAST('Unknown' AS VARCHAR(20))                    AS day_name
    , CAST('Unknown' AS VARCHAR(7))                     AS year_month
    , CAST(NULL AS DATE)                                AS month_start_date
    , CAST(NULL AS DATE)                                AS quarter_start_date
    , CAST(NULL AS BOOLEAN)                             AS is_weekend

UNION ALL

SELECT
      date_key
    , full_date
    , year_number
    , quarter_number
    , month_number
    , month_name
    , week_number
    , day_number
    , day_name
    , year_month
    , month_start_date
    , quarter_start_date
    , is_weekend
FROM known_dates