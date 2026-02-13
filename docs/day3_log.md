# Day 3 – Advanced Commerce Intelligence Layer

## Objective
Move from reporting analytics to decision-aware intelligence system.

---

## 1. Order-Level Profitability

Rolled item-level contribution margin to order-level in fct_orders.

Added:
- order_contribution_margin
- order_contribution_margin_pct

Why:
Revenue alone is not enough. Scaling must consider profitability.

---

## 2. Weekly Margin KPI

Built weekly_margin_summary model:
- total_revenue
- total_contribution_margin
- contribution_margin_pct

This allows margin monitoring at strategic level.

---

## 3. Margin Guardrail

Added guardrail:
low_contribution_margin

Rule:
If contribution_margin_pct is NULL or < 15% → fail

Reason:
If revenue is zero or margin is weak, scaling spend is unsafe.

---

## 4. Guardrail Evaluation Engine

Built dynamic evaluation system:
- Reads latest weekly metrics
- Evaluates all guardrails
- Determines blocking logic

Now guardrails include:
- high_cancellation_rate
- revenue_payment_mismatch
- low_data_coverage
- low_contribution_margin

---

## 5. Action Recommendation Logic

Simulated growth action:
"increase_paid_spend"

If guardrails fail:
- recommendation_status = blocked
- explanation lists failing guardrails

---

## 6. Decision & Action Logging

Seeds:
- context_decisions
- context_actions

View:
- decision_action_view

This simulates how an AI system could:
- Evaluate metrics
- Recommend action
- Log decision
- Log execution status

---

## Final Architecture

Raw Data → Staging → Facts → KPIs → Guardrails → Recommendation → Decision Log


