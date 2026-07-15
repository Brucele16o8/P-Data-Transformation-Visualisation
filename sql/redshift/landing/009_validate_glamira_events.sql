/*
 Total rows
 */
SELECT
      COUNT(*) AS total_rows
FROM landing.glamira_events;

/*
 Check missing essential attributes
 */
 SELECT
      SUM
      (
          CASE
              WHEN event_data._id IS NULL
                  THEN 1
              ELSE 0
          END
      ) AS missing_mongo_id_rows
    , SUM
      (
          CASE
              WHEN event_data.collection IS NULL
                  THEN 1
              ELSE 0
          END
      ) AS missing_event_type_rows
    , SUM
      (
          CASE
              WHEN event_data.time_stamp IS NULL
                  THEN 1
              ELSE 0
          END
      ) AS missing_timestamp_rows
FROM landing.glamira_events;

/*
 Count distinct MongoDB IDs
 */
 SELECT
      COUNT(*)                                        AS total_rows
    , COUNT(DISTINCT JSON_SERIALIZE(event_data._id))  AS distinct_mongo_ids
    , COUNT(*)
      - COUNT(DISTINCT JSON_SERIALIZE(event_data._id)) AS duplicate_rows
FROM landing.glamira_events;

/*
Event-type distribution
 */
 SELECT
      event_data.collection::VARCHAR  AS event_type
    , COUNT(*)                        AS event_count
FROM landing.glamira_events
GROUP BY
      event_data.collection::VARCHAR
ORDER BY
      event_count DESC;

/*
 Event-time range
 */
 SELECT
      MIN(event_data.time_stamp::BIGINT) AS minimum_epoch_seconds
    , MAX(event_data.time_stamp::BIGINT) AS maximum_epoch_seconds
    , DATEADD
      (
          SECOND
        , MIN(event_data.time_stamp::BIGINT)
        , TIMESTAMP '1970-01-01 00:00:00'
      ) AS earliest_event_timestamp
    , DATEADD
      (
          SECOND
        , MAX(event_data.time_stamp::BIGINT)
        , TIMESTAMP '1970-01-01 00:00:00'
      ) AS latest_event_timestamp
FROM landing.glamira_events;

/*
 Product-related event counts
 */
 SELECT
      COUNT(*) AS product_related_event_rows
FROM landing.glamira_events
WHERE event_data.product_id IS NOT NULL
   OR event_data.viewing_product_id IS NOT NULL;

/*
 Order-related rows
 */
 SELECT
      event_data.collection::VARCHAR  AS event_type
    , COUNT(*)                        AS row_count
FROM landing.glamira_events
WHERE event_data.order_id IS NOT NULL
   OR event_data.cart_products IS NOT NULL
GROUP BY
      event_data.collection::VARCHAR
ORDER BY
      row_count DESC;