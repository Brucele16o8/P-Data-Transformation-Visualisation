{% macro hash_pii(column_expression) %}

CASE
    WHEN {{ column_expression }} IS NULL
      OR TRIM(CAST({{ column_expression }} AS VARCHAR)) = ''
        THEN NULL

    ELSE SHA2
         (
               '{{ env_var("DBT_PII_HASH_SALT") }}'
               || '|'
               || LOWER
                  (
                      TRIM
                      (
                          CAST
                          (
                              {{ column_expression }}
                              AS VARCHAR
                          )
                      )
                  )
           , 256
         )
END

{% endmacro %}