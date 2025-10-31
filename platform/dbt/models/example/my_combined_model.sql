-- Downstream model that combines both upstream models
-- Adds load_dts timestamp for tracking when data was loaded

{{ config(materialized='table') }}

with first_model as (
    select *
    from {{ ref('my_first_dbt_model') }}
),

second_model as (
    select *
    from {{ ref('my_second_dbt_model') }}
),

combined as (
    select
        coalesce(f.id, s.id) as id,
        f.id as first_model_id,
        s.id as second_model_id,
        s.a_message,
        current_timestamp as load_dts
    from first_model f
    full outer join second_model s
        on f.id = s.id
)

select *
from combined

