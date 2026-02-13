with d as (
    select * from {{ ref('context_decisions') }}
),

a as (
    select * from {{ ref('context_actions') }}
),

final as (

    select
        d.decision_id,
        d.decision_ts,
        d.week_start_date,
        d.question,
        d.insight,
        d.recommendation,
        d.recommendation_status,
        d.guardrails_triggered,

        a.action_id,
        a.action_ts,
        a.action_type,
        a.status as action_status,
        a.payload

    from d
    left join a
      on d.decision_id = a.decision_id

)

select * from final
