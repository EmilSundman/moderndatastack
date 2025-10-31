{% macro checkpoint_wal() %}
  {% if execute %}
    {% set query %}
      CHECKPOINT;
    {% endset %}
    {% do run_query(query) %}
  {% endif %}
{% endmacro %}

