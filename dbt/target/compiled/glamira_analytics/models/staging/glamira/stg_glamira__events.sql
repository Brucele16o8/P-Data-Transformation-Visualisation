

WITH stg_glamira__events__source AS
(
    SELECT
          event_data
        , loaded_at
    FROM "glamira_analytics"."landing"."glamira_events"
)

, stg_glamira__events__rename AS
(
    SELECT
          event_data._id."$oid"::VARCHAR                AS event_id_raw
        , event_data.collection::VARCHAR                AS event_type_raw
        , event_data.time_stamp::VARCHAR                AS event_epoch_seconds_raw
        , event_data.local_time::VARCHAR                AS local_time_raw
        , event_data.user_id_db::VARCHAR                AS customer_id_raw
        , event_data.email_address::VARCHAR             AS email_address_raw
        , event_data.device_id::VARCHAR                 AS device_id_raw
        , event_data.ip::VARCHAR                        AS ip_address_raw
        , event_data.store_id::VARCHAR                  AS store_id_raw
        , event_data.order_id::VARCHAR                  AS order_id_raw
        , event_data.user_agent::VARCHAR                AS user_agent_raw
        , event_data.resolution::VARCHAR                AS screen_resolution_raw
        , event_data.current_url::VARCHAR               AS current_url_raw
        , event_data.referrer_url::VARCHAR              AS referrer_url_raw
        , event_data.cart_products                      AS cart_products
        , event_data                                    AS raw_event
        , loaded_at
    FROM stg_glamira__events__source
)

, stg_glamira__events__cast_type AS
(
    SELECT
          NULLIF(TRIM(event_id_raw), '')                 AS event_id
        , NULLIF(TRIM(event_type_raw), '')               AS event_type
        , TRY_CAST
          (
              NULLIF(TRIM(event_epoch_seconds_raw), '')
              AS BIGINT
          )                                              AS event_epoch_seconds
        , NULLIF(TRIM(local_time_raw), '')               AS local_time_raw
        , TRY_CAST
          (
              NULLIF(TRIM(local_time_raw), '')
              AS TIMESTAMP
          )                                              AS local_event_timestamp
        , NULLIF(TRIM(customer_id_raw), '')              AS customer_id
        , NULLIF(LOWER(TRIM(email_address_raw)), '')     AS email_address
        , NULLIF(TRIM(device_id_raw), '')                AS device_id
        , NULLIF(TRIM(ip_address_raw), '')               AS ip_address
        , NULLIF(TRIM(store_id_raw), '')                 AS store_id
        , NULLIF(TRIM(order_id_raw), '')                 AS order_id
        , NULLIF(TRIM(user_agent_raw), '')               AS user_agent
        , NULLIF(TRIM(screen_resolution_raw), '')        AS screen_resolution
        , NULLIF(TRIM(current_url_raw), '')              AS current_url
        , NULLIF(TRIM(referrer_url_raw), '')             AS referrer_url
        , cart_products
        , raw_event
        , loaded_at
    FROM stg_glamira__events__rename
)
, stg_glamira__events__final AS
(
    SELECT
          event_id
        , event_type
        , event_epoch_seconds
        , CASE
            WHEN event_epoch_seconds IS NOT NULL
                THEN DATEADD
                (
                    SECOND
                    , event_epoch_seconds
                    , TIMESTAMP '1970-01-01 00:00:00'
                )
            ELSE NULL
        END                                               AS event_timestamp_utc
        , local_event_timestamp
        , local_time_raw
        , customer_id
        , email_address
        , device_id
        , ip_address
        , store_id
        , order_id
        , user_agent
        , screen_resolution
        , current_url
        , referrer_url
        , cart_products
        , raw_event
        , loaded_at
    FROM stg_glamira__events__cast_type
)

SELECT *
FROM stg_glamira__events__final