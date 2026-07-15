CREATE SCHEMA IF NOT EXISTS landing;

CREATE TABLE IF NOT EXISTS landing.glamira_events
(
      event_data  SUPER
    , loaded_at   TIMESTAMPTZ DEFAULT GETDATE()
);