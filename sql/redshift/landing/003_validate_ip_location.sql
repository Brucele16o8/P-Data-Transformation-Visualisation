/*
 Check total and distinct IP counts
 */
SELECT
      COUNT(*)                                  AS total_rows
    , COUNT(DISTINCT ip)                        AS distinct_ips
    , COUNT(*) - COUNT(DISTINCT ip)             AS duplicate_rows
FROM landing.ip_location_lookup;

/*
 Check missing IP addresses
 */
SELECT
      COUNT(*) AS missing_ip_rows
FROM landing.ip_location_lookup
WHERE ip IS NULL
   OR TRIM(ip) = '';

/*
Check status distribution
 */
SELECT
      status
    , COUNT(*) AS row_count
FROM landing.ip_location_lookup
GROUP BY
      status
ORDER BY
      row_count DESC;

/*
 Check successful rows without a country
 */
SELECT
      COUNT(*) AS ok_without_country
FROM landing.ip_location_lookup
WHERE status = 'ok'
  AND country IS NULL;

/*
 Check literal placeholder values
 */
SELECT COUNT(*) AS unresolved_location_rows
FROM landing.ip_location_lookup
WHERE country IS NULL
  AND region IS NULL
  AND city IS NULL;

/*
Check processing and load timestamps
 */
 SELECT
      MIN(processed_at) AS earliest_processed_at
    , MAX(processed_at) AS latest_processed_at
    , MIN(loaded_at)    AS load_started_at
    , MAX(loaded_at)    AS load_finished_at
FROM landing.ip_location_lookup;

/*
 Find duplicate IP addresses
 */
SELECT
      ip
    , COUNT(*) AS occurrences
FROM landing.ip_location_lookup
GROUP BY
      ip
HAVING COUNT(*) > 1
ORDER BY
      occurrences DESC
LIMIT 100;