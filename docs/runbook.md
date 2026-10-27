# Runbook

## When ingestion fails

### Symptoms

- Email from SNS: "Ingest Lambda failed"
- CloudWatch alarm: `health-lake-ingest-errors-{env}` in ALARM state
- No new object under `s3://{bucket}/raw/owid/ingest_date=.../`

### Steps

1. **Check Lambda logs**
   ```bash
   aws logs tail /aws/lambda/health-lake-ingest-dev --since 1h
   ```
2. **Common causes**
   - OWID URL changed or rate-limited → update `OWID_URL` in `lambda/ingest/handler.py`
   - Lambda timeout (120s) → increase timeout in Terraform if download is slow
   - IAM permission denied → verify ingest role can `PutObject` on `raw/*`
3. **Manual retry**
   ```bash
   aws lambda invoke --function-name health-lake-ingest-dev \
     --payload '{"ingest_date": "YYYY-MM-DD"}' /tmp/out.json && cat /tmp/out.json
   ```
4. **Confirm SNS subscription** — check email for AWS SNS confirmation link if alerts never arrive.

---

## When cleaning fails (after raw upload)

### Symptoms

- SNS: "Clean Lambda failed after raw file upload"
- Raw file exists but no matching Parquet in `clean/`
- Rejected rows may appear in `quarantine/rejected/`

### Steps

1. **Check clean Lambda logs**
   ```bash
   aws logs tail /aws/lambda/health-lake-clean-dev --since 1h
   ```
2. **Inspect quarantine**
   ```bash
   aws s3 ls s3://YOUR-BUCKET/quarantine/rejected/ --recursive
   ```
3. **Re-run clean locally** (after scripts are added in later build days):
   ```bash
   export DATA_LAKE_BUCKET=YOUR-BUCKET
   python scripts/clean_s3.py --key raw/owid/ingest_date=2026-10-05/vaccination_coverage.csv
   ```
4. **If VPC-enabled clean Lambda cannot reach Secrets Manager** — enable `enable_secrets_manager_endpoint = true` temporarily, or disable RDS integration.

---

## When Athena returns no data

1. Confirm Parquet exists:
   ```bash
   aws s3 ls s3://BUCKET/clean/ --recursive | head
   aws s3 ls s3://BUCKET/curated/ --recursive
   ```
2. Run Glue crawler manually (IAM role needs Glue catalog + S3 read; `AWSGlueServiceRole` attached in Terraform):
   ```bash
   aws glue start-crawler --name health-lake-clean-dev
   aws glue get-crawler --name health-lake-clean-dev \
     --query 'Crawler.[State,LastCrawl.Status,LastCrawl.ErrorMessage]' --output text
   ```
3. Wait for `READY` and `LastCrawl` **SUCCEEDED**. List catalog tables:
   ```bash
   aws glue get-tables --database-name health_lake_dev --query 'TableList[*].Name' --output table
   ```
   Expect **`fact_health_indicator`**, **`dim_region`**, and often **`clean`** (merged `clean/` prefix). There is usually **no** separate `measles_mcv1` table.
4. Query in Athena workgroup **`health-lake-dev`**, database **`health_lake_dev`**. Use [`sql/vaccination_by_region.sql`](../sql/vaccination_by_region.sql) (joins fact + dim) or create views from [`sql/create_views.sql`](../sql/create_views.sql).
5. **SQL runs in the Athena query editor**, not in the Linux shell. CLI example:
   ```bash
   aws athena start-query-execution \
     --work-group health-lake-dev \
     --query-execution-context Database=health_lake_dev \
     --result-configuration OutputLocation=s3://BUCKET/athena-results/ \
     --query-string "SHOW TABLES IN health_lake_dev"
   ```
   Poll with `aws athena get-query-execution` until `SUCCEEDED`, then `get-query-results`.

---

## When Terraform apply fails in CI

1. Check GitHub Actions log for `terraform plan` / `apply` error.
2. Verify OIDC role trust matches repo: `repo:YOUR_USER/aws-public-health-data-lake:*`
3. Confirm state bucket exists and backend bucket name is correct.
4. Run locally:
   ```bash
   cd terraform/envs/dev
   terraform init
   terraform plan -var-file=dev.tfvars
   ```

---

## Emergency: destroy everything

```bash
cd terraform/envs/dev
terraform destroy -var-file=dev.tfvars
```

State bucket is created outside Terraform (`scripts/bootstrap_tf_state.sh`) — delete manually if no longer needed.

---

## Weekly health check

- [ ] Budget alert not triggered
- [ ] Last `raw/` ingest_date is within 7 days
- [ ] CloudWatch ingest/clean error alarms OK
- [ ] Athena test query returns rows
- [ ] No unexpected resources in Cost Explorer (tag: `project=health-lake`)
