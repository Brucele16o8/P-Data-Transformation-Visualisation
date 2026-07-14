CREATE SCHEMA IF NOT EXISTS landing;

CREATE TABLE IF NOT EXISTS landing.ip_location_lookup
(
      ip              VARCHAR(45)
    , country         VARCHAR(128)
    , region          VARCHAR(256)
    , city            VARCHAR(256)
    , latitude        DOUBLE PRECISION
    , longitude       DOUBLE PRECISION
    , processed_at    TIMESTAMPTZ
    , status          VARCHAR(32)
    , error_message   VARCHAR(2048)
    , loaded_at       TIMESTAMPTZ DEFAULT GETDATE()
);