# Day 1 Log — Snowflake + dbt Setup

## Goal
Set up the analytics stack (Snowflake + dbt) and build the first staging model.

## What I completed
- Installed and configured Git + Python virtual environment on Windows
- Created Snowflake objects:
  - Warehouse: CHORD_WH
  - Database: CHORD_DB
  - Schemas: RAW, ANALYTICS
- Loaded raw Olist orders data into: CHORD_DB.RAW.OLIST_ORDERS_DATASET
- Initialized dbt project: chord_commerce
- Added dbt source definition for RAW orders
- Built first staging model: ANALYTICS.STG_ORDERS
- Added and ran dbt tests:
  - not_null on ORDER_ID
  - unique on ORDER_ID

## Commands run
- dbt debug
- dbt run --select stg_orders
- dbt test --select stg_orders
- dbt docs generate

## Result
STG_ORDERS is available in Snowflake and tests pass successfully.
