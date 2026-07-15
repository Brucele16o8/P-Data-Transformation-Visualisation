/*
 Check row and product counts
 */
SELECT
      COUNT(*)                        AS total_rows
    , COUNT(DISTINCT product_id)      AS distinct_product_ids
    , COUNT(DISTINCT store_code)      AS distinct_store_codes
FROM landing.product_information;

/*
 Check crawl statuses
 */
 SELECT
      status
    , COUNT(*) AS row_count
FROM landing.product_information
GROUP BY
      status
ORDER BY
      row_count DESC;

/*
Check missing product identifiers
 */
 SELECT
      COUNT(*) AS missing_product_id_rows
FROM landing.product_information
WHERE product_id IS NULL
   OR TRIM(product_id) = '';

/*
Check exact duplicate crawl records
 */
 SELECT
      product_id
    , store_code
    , scraped_at
    , COUNT(*) AS occurrences
FROM landing.product_information
GROUP BY
      product_id
    , store_code
    , scraped_at
HAVING COUNT(*) > 1
ORDER BY
      occurrences DESC
LIMIT 100;

/*
 Preview fields required by dim_product
 */
 SELECT
      product_id
    , sku
    , COALESCE(product_name, name)                    AS product_name
    , react_data_basic.product_type::VARCHAR          AS product_type
    , category_name
    , react_data_basic.collection::VARCHAR            AS collection
    , react_data_basic.min_price::VARCHAR             AS min_price_raw
    , react_data_basic.max_price::VARCHAR             AS max_price_raw
    , store_code
    , active
    , scraped_at
FROM landing.product_information
LIMIT 20;