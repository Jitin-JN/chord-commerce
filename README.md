
## Overview

This project simulates a context-aware commerce intelligence system inspired by modern AI-driven decision infrastructure.

Instead of stopping at dashboards, this system:

- Builds revenue and profitability models
- Performs revenue-payment reconciliation checks
- Evaluates operational guardrails
- Blocks unsafe growth actions
- Logs decisions and simulated actions

---

## Key Features

- Snowflake-based analytics warehouse
- dbt-powered transformation layers
- Profitability modeling (Contribution Margin)
- Guardrail engine with dynamic evaluation
- Decision + Action logging layer
- Clean test coverage across models and seeds

---


## Architecture Overview


<img width="1024" height="1536" alt="architecture" src="https://github.com/user-attachments/assets/67ee7898-2b54-46e7-a6d8-bea9803ea43d" />

---

## My thougt process

I built an end-to-end commerce analytics system using Snowflake and dbt, structured in layered architecture similar to how production analytics teams operate.

First I loaded raw ecommerce data into Snowflake and created staging models in dbt to clean and standardize the data.
Then I built fact tables at two grains - item-level and order-level, so metrics could be calculated correctly without duplication issues.

On top of that, I created daily and weekly KPI models, including revenue, AOV and cancellation rate. I made sure weekly AOV was calculated correctly as total revenue divided by total orders instead of averaging daily AOV to avoid aggregation errors.

Then I added a revenue reconciliation model that compares item-level revenue with payment totals and classifies mismatches. This helps detect data quality or operational issues.

The most important part is I built a context layer. I created guardrail tables that define business safety rules. For example: do not scale paid spend if cancellation rate exceeds 3% or revenue-payment mismatches exceed 1%.

I built a guardrail evaluation model that checks current KPIs against these rules. Then I created a recommendation model that proposes actions but blocks them automatically if guardrails fail.

Then I extended the system further by introducing profitability modeling. Instead of evaluating only revenue, I calculated contribution margin at the item level and rolled it up to the order level. Then I built a weekly margin summary model to monitor contribution margin percentage over time.

I added a new guardrail: low contribution margin. If margin is below 15% or if revenue is zero and margin cannot be calculated then the system automatically blocks growth actions. This prevents scaling spend when profitability is weak or unknown.

Finally, I implemented decision and action logs to simulate how an AI system could safely recommend and track actions over time.

So the system goes from data → metrics → guardrails → recommendations → decision logging, which is closer to an agent-ready analytics workflow rather than just dashboards.

---

## Dashboard Snapshots

- Executive Commerce Snapshot: “How is the business doing?”

<img width="1001" height="563" alt="image" src="https://github.com/user-attachments/assets/ccdb2341-455f-43bb-95f3-b5be111e4728" />


<br><br>

- Growth Diagnostics: “What changed WoW and why?”

<img width="1003" height="565" alt="image" src="https://github.com/user-attachments/assets/d799168f-1b2e-4daf-80d7-83ed5a3b126b" />

---

## Data Model and Grains

| Model                    | Grain                        | Purpose               |
| ------------------------ | ---------------------------- | --------------------- |
| `fct_order_items`        | 1 row per order item         | item revenue + margin |
| `fct_orders`             | 1 row per order              | order totals          |
| `weekly_orders_summary`  | 1 row per week               | weekly KPIs           |
| `guardrail_evaluation`   | 1 row per guardrail per week | pass/fail + blocks    |
| `action_recommendations` | 1 row per week               | action + explanation  |

