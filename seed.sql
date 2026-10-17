INSERT INTO "LiteLLM_SpendLogs"
("request_id", "call_type", "api_key", "spend", "total_tokens", "prompt_tokens", "completion_tokens",
 "startTime", "endTime", "model", "model_group", "metadata", "status", "updated_at")
SELECT 'qa-filter-' || n, 'completion', 'local-history-fixture', 0.001, 30, 20, 10,
       TIMESTAMP '2026-10-17 10:00:00' + n * INTERVAL '1 minute',
       TIMESTAMP '2026-10-17 10:00:01' + n * INTERVAL '1 minute',
       'filter-demo', 'filter-demo',
       CASE
         WHEN n <= 12 THEN '{"user_api_key_alias":"health-check-service"}'::jsonb
         WHEN n <= 16 THEN '{"user_api_key_alias":"support-service"}'::jsonb
         ELSE '{}'::jsonb
       END,
       'success', NOW()
FROM generate_series(1, 18) n
ON CONFLICT ("request_id") DO NOTHING;
