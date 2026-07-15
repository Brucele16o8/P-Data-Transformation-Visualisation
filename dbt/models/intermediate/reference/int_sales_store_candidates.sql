{{
    config(
          materialized='view'
        , static_analysis='off'
    )
}}

WITH sales_order_lines AS
(
    SELECT
          event_id
        , store_id
        , order_id
        , currency_symbol
    FROM {{ ref('int_checkout_success__order_lines') }}
    WHERE store_id IS NOT NULL
)

, sales_events AS
(
    SELECT DISTINCT
          event_id
        , store_id
    FROM sales_order_lines
)

, extracted_domains AS
(
    SELECT
          sales.store_id
        , LOWER
          (
              REPLACE
              (
                  SPLIT_PART
                  (
                      SPLIT_PART
                      (
                            events.current_url
                          , '://'
                          , 2
                      )
                    , '/'
                    , 1
                  )
                , 'www.'
                , ''
              )
          )                                             AS store_domain
    FROM sales_events AS sales
    INNER JOIN {{ ref('stg_glamira__events') }} AS events
        ON sales.event_id = events.event_id
    WHERE events.current_url IS NOT NULL
      AND events.current_url LIKE 'http%'
)

, domain_counts AS
(
    SELECT
          store_id
        , store_domain
        , COUNT(*)                                      AS domain_event_count
    FROM extracted_domains
    WHERE store_domain IS NOT NULL
      AND store_domain <> ''
    GROUP BY
          store_id
        , store_domain
)

, ranked_domains AS
(
    SELECT
          store_id
        , store_domain
        , domain_event_count
        , ROW_NUMBER() OVER
          (
              PARTITION BY store_id
              ORDER BY
                    domain_event_count DESC
                  , store_domain
          )                                             AS domain_rank
    FROM domain_counts
)

, currency_counts AS
(
    SELECT
          store_id
        , currency_symbol
        , COUNT(*)                                      AS currency_line_count
    FROM sales_order_lines
    WHERE currency_symbol IS NOT NULL
      AND TRIM(currency_symbol) <> ''
    GROUP BY
          store_id
        , currency_symbol
)

, ranked_currencies AS
(
    SELECT
          store_id
        , currency_symbol
        , currency_line_count
        , ROW_NUMBER() OVER
          (
              PARTITION BY store_id
              ORDER BY
                    currency_line_count DESC
                  , currency_symbol
          )                                             AS currency_rank
    FROM currency_counts
)

, sales_counts AS
(
    SELECT
          store_id
        , COUNT(DISTINCT order_id)                      AS order_count
        , COUNT(*)                                      AS order_line_count
    FROM sales_order_lines
    GROUP BY
          store_id
)

SELECT
      sales.store_id
    , domain.store_domain
    , currency.currency_symbol
    , sales.order_count
    , sales.order_line_count
    , domain.domain_event_count
    , currency.currency_line_count
FROM sales_counts AS sales
LEFT JOIN ranked_domains AS domain
    ON sales.store_id = domain.store_id
   AND domain.domain_rank = 1
LEFT JOIN ranked_currencies AS currency
    ON sales.store_id = currency.store_id
   AND currency.currency_rank = 1