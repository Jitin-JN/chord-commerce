# Day 2 – Staging Completion & First Fact Table

## Objective
Build complete staging layer and create the first mart-level fact table for ecommerce revenue analysis.

---

## What Was Done

### 1. Completed Staging Models

Created staging models for:

- stg_customers
- stg_orders
- stg_order_items
- stg_payments
- stg_products
- stg_product_category_translation

Purpose:
Clean raw data and standardize column names before applying business logic.

---

### 2. Added Data Tests

Added tests for:
- not_null
- unique
- accepted_values (for payment_type)

Ran:
dbt test

All tests passed successfully.

This ensures data reliability before building fact tables.

---

### 3. Built First Fact Table – fct_order_items

Grain:
One row per order item (order_id + order_item_id).

Joined:
- stg_order_items
- stg_orders
- stg_customers
- stg_products
- stg_product_category_translation

Calculated:
item_gross_revenue = price + freight_value

Successfully created:
CHORD_DB.ANALYTICS.FCT_ORDER_ITEMS


---

## Result

Analytics layer now has:

- Clean staging models
- Data quality tests
- First mart-level revenue model
