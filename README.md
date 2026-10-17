# LiteLLM #44570 current-tip evidence

Captured on October 17, 2026.

- Before: actual merge base `9d72bae336ec0d14c41651adcb0d2e1149721f46`
- After: PR tip `01dde982363ba6a8fc55b2ec7752606e5188a9f1`
- Both browser sessions used `http://127.0.0.1:3000/logs?exclude_key_alias=health-check-service`, the same viewport and the same isolated PostgreSQL database. The dev UI server was switched between the two exact source trees, not simulated by toggling the feature.
- Production Next UI, proxy routes, Prisma and PostgreSQL execute normally. No browser/API response mocking.
- The dataset is **18 synthetic historical spend-log records**, inserted by `seed.sql`, not real model completions or production customer data. Key aliases were provisioned through the real local `/key/generate` endpoint so autocomplete uses the normal proxy path.
- No LLM call or paid provider is needed to reproduce filtering of existing logs. This does not validate provider inference or production deployment authentication.

## Observed browser behavior

1. Before, the bookmarked exclusion URL displays all 18 records, including 12 `health-check-service` rows. The filter drawer lacks an exclusion operator.
2. After, the same URL displays 6 records: 4 `support-service` rows and 2 rows with no alias. The visible filter chip says `Key Alias is not: health-check-service`.
3. After, reopening Filters restores `is not`. Clearing the selected alias keeps that operator; selecting `support-service` displays 14 records, with no `support-service` row. Reloading restores that URL and result.

Red boxes are the only screenshot annotations. `*-control.png` captures are unannotated. Videos record actual interactions; the fixture log values were not edited into the UI.

## Observed real HTTP/SQL behavior

Both source versions received the same real request:

```sh
curl -G "$PROXY_URL/spend/logs/v2" \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  --data-urlencode start_date=2026-10-17 \
  --data-urlencode end_date=2026-10-17 \
  --data-urlencode exclude_key_alias=health-check-service \
  --data-urlencode page_size=2 \
  --data-urlencode page=1
```

- Before (`PROXY_URL=http://127.0.0.1:4001`): total 18, 9 pages; unknown exclusion parameter has no effect
- After (`PROXY_URL=http://127.0.0.1:4000`): total 6, 3 pages; first page contains the 2 unaliased records
- After page 3: `qa-filter-14` and `qa-filter-13`, both `support-service`, proving exclusion is applied before pagination

The videos/HTTP replay do not re-prove exact-whitespace behavior; those regressions remain separately covered by source tests. Historical test counts are not presented as rerun by this media capture.
