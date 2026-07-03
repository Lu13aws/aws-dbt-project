-- Run this once before loading data.
-- Replace arn:aws:iam::759302162548:role/redshift-s3-copy-role and olist-raw-data-759302162548-eu-central-1-an with your actual values.
-- Execute in Redshift Query Editor v2 or any Redshift client.

CREATE SCHEMA IF NOT EXISTS raw;
