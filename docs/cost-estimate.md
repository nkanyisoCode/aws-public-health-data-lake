# Cost Estimate (dev environment, af-south-1)

Assumes minimal usage, resources destroyed when not actively working.

## Monthly breakdown

| Service | Assumption | Est. cost |
|---------|------------|-----------|
| S3 storage | ~500 MB raw + clean + curated | $0.01 |
| S3 requests | Weekly ingest + clean, ~1k PUT/GET | $0.01 |
| Lambda | 4 ingest + 4 clean runs/month, 512 MB | $0.00 (free tier) |
| EventBridge | 4 scheduled rules/month | $0.00 |
| Glue Crawler | 4 on-demand runs, ~1 DPU-hour each | $0.44 |
| Athena | 10 queries, ~100 MB scanned each | $0.05 |
| CloudWatch | Logs + 2 alarms | $0.10 |
| SNS | Few emails/month | $0.00 |
| CloudTrail | First trail free (management events) | $0.00 |
| AWS Budget | Free | $0.00 |
| **Subtotal (core pipeline)** | | **~$0.60/month** |

## Optional add-ons (disable when not needed)

| Service | Assumption | Est. cost |
|---------|------------|-----------|
| RDS db.t4g.micro | 730 hrs/month if left running | ~$12–18 |
| NAT Gateway | Not used (by design) | $0 |
| Secrets Manager VPCE | 2 AZs × ~$7/AZ if enabled | ~$14 |
| GuardDuty | After 30-day trial | ~$1–3 |
| AWS Config | Per recorded resource | ~$2–5 |
| **Subtotal (full stack left on)** | | **~$30–40/month** |

## Cost controls in this repo

1. **AWS Budget** — `$5/month` in dev, alert at 80% (filtered by `project=health-lake` tag).
2. **Lifecycle rules** — `raw/` → Standard-IA (30d) → Glacier (90d); `athena-results/` expire in 7d; `quarantine/` expire in 30d.
3. **Athena workgroup** — `bytes_scanned_cutoff_per_query` limits runaway queries (1 GB dev, 5 GB prod).
4. **Feature flags in tfvars** — RDS, GuardDuty, Config, and Secrets Manager endpoint default to **off** in dev.
5. **Parquet not CSV** in clean zone — smaller storage and cheaper Athena scans.

## Recommendation

- Run **core pipeline only** for daily portfolio work: **under $1/month**.
- Enable VPC/RDS/Config/GuardDuty only for the milestone demo, then `terraform destroy` or set flags back to `false`.
- Activate cost allocation tags (`project`, `env`) in the Billing console; group by `env` in Cost Explorer.
