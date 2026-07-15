COPY landing.glamira_events
(
      event_data
)
FROM 's3://glamira-data-lake-20260611/processed/source=glamira/dataset=events/ingestion_date=2026-07-14/'
IAM_ROLE DEFAULT
REGION 'ap-southeast-2'
FORMAT AS JSON 'noshred'
GZIP;

/*
 Preview the landing data
 */
 SELECT
      event_data.collection::VARCHAR          AS event_type
    , event_data.product_id::VARCHAR          AS product_id
    , event_data.viewing_product_id::VARCHAR  AS viewing_product_id
    , event_data.order_id                     AS order_id_raw
    , event_data.ip::VARCHAR                  AS ip_address
    , event_data.store_id::VARCHAR            AS store_id
    , event_data.currency::VARCHAR            AS currency
    , event_data.price::VARCHAR               AS price_raw
    , event_data.time_stamp::BIGINT           AS event_epoch_seconds
    , event_data.local_time::VARCHAR          AS local_time_raw
    , loaded_at
FROM landing.glamira_events
LIMIT 20;

/*
 Preview the landing data
 */
 SELECT
      event_data.collection::VARCHAR     AS event_type
    , event_data.product_id::VARCHAR     AS product_id
    , JSON_SERIALIZE(event_data.option)  AS option_json
FROM landing.glamira_events
WHERE event_data.option IS NOT NULL
LIMIT 20;

/*
 Cart products
 */
 SELECT
      event_data.collection::VARCHAR            AS event_type
    , event_data.order_id                       AS order_id_raw
    , JSON_SERIALIZE(event_data.cart_products)  AS cart_products_json
FROM landing.glamira_events
WHERE event_data.cart_products IS NOT NULL
LIMIT 20;
