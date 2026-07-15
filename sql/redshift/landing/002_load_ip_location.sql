-- BEGIN;

-- TRUNCATE TABLE landing.ip_location_lookup;

COPY landing.ip_location_lookup
(
      ip
    , country
    , region
    , city
    , latitude
    , longitude
    , processed_at
    , status
    , error_message
)
FROM 's3://glamira-data-lake-20260611/processed/source=ip2location/dataset=ip_location_lookup/processing_date=2026-07-14/'
IAM_ROLE DEFAULT
FORMAT AS JSON 'auto'
TIMEFORMAT 'auto'
REGION 'ap-southeast-2';

-- COMMIT;