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

1. Confirm Parquet exists: `aws s3 ls s3://BUCKET/clean/ --recursive`
2. Run Glue crawler manually:
   ```bash
   aws glue start-crawler --name health-lake-clean-dev
   aws glue get-crawler --name health-lake-clean-dev --query Crawler.State
   ```
3. Wait for `READY`, then query in Athena workgroup `health-lake-dev`.
4. Use SQL from `sql/vaccination_by_region.sql`.

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
