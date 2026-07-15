CREATE SCHEMA IF NOT EXISTS landing;

CREATE TABLE IF NOT EXISTS landing.product_information
(
      requested_product_id  VARCHAR(50)
    , product_id            VARCHAR(50)
    , source_url            VARCHAR(8192)
    , original_url          VARCHAR(8192)
    , resolved_url          VARCHAR(8192)
    , country_store         VARCHAR(10)
    , crawl_url_strategy    VARCHAR(128)
    , product_name          VARCHAR(1024)
    , name                  VARCHAR(1024)
    , sku                   VARCHAR(255)
    , category              VARCHAR(50)
    , category_name         VARCHAR(512)
    , price                 VARCHAR(50)
    , currency              VARCHAR(20)
    , store_code            VARCHAR(50)
    , active                BOOLEAN
    , scraped_at            TIMESTAMPTZ
    , status                VARCHAR(50)
    , failure_reason        VARCHAR(2048)
    , error_message         VARCHAR(8192)
    , react_data_basic      SUPER
    , react_data            SUPER
    , loaded_at             TIMESTAMPTZ DEFAULT GETDATE()
);