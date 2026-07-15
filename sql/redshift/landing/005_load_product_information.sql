COPY landing.product_information
(
      requested_product_id
    , product_id
    , source_url
    , original_url
    , resolved_url
    , country_store
    , crawl_url_strategy
    , product_name
    , name
    , sku
    , category
    , category_name
    , price
    , currency
    , store_code
    , active
    , scraped_at
    , status
    , failure_reason
    , error_message
    , react_data_basic
    , react_data
)
FROM 's3://glamira-data-lake-20260611/processed/source=glamira/dataset=product_information/snapshot_date=2026-07-14/'
IAM_ROLE DEFAULT
REGION 'ap-southeast-2'
FORMAT AS JSON 'auto'
TIMEFORMAT 'auto';