WITH source_events AS
(
    SELECT
          event_data
        , loaded_at
    FROM {{ source('landing', 'glamira_events') }}
)

SELECT
      JSON_SERIALIZE(event_data._id)              AS mongo_id_json
    , event_data.collection::VARCHAR              AS event_type
    , event_data.time_stamp::BIGINT               AS event_epoch_seconds
    , DATEADD
      (
          SECOND
        , event_data.time_stamp::BIGINT
        , TIMESTAMP '1970-01-01 00:00:00'
      )                                           AS event_timestamp_utc
    , event_data.local_time::VARCHAR              AS local_time_raw
    , event_data.user_id_db::VARCHAR              AS customer_id
    , event_data.email_address::VARCHAR           AS email_address
    , event_data.device_id::VARCHAR               AS device_id
    , event_data.ip::VARCHAR                      AS ip_address
    , event_data.store_id::VARCHAR                AS store_id
    , event_data.product_id::VARCHAR              AS product_id
    , event_data.viewing_product_id::VARCHAR      AS viewing_product_id
    , event_data.order_id                         AS order_id_raw
    , event_data.price::VARCHAR                   AS price_raw
    , event_data.currency::VARCHAR                AS currency_raw
    , event_data.current_url::VARCHAR             AS current_url
    , event_data.referrer_url::VARCHAR            AS referrer_url
    , event_data.user_agent::VARCHAR              AS user_agent
    , event_data.resolution::VARCHAR              AS screen_resolution
    , event_data.show_recommendation::VARCHAR     AS show_recommendation_raw
    , event_data.option                           AS option_data
    , event_data.cart_products                    AS cart_products
    , event_data                                  AS raw_event
    , loaded_at
FROM source_events;