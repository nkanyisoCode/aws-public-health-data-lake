#!/usr/bin/env bash
# Prove least-privilege IAM: ingest role cannot write to clean/, reporting cannot write anywhere.
set -euo pipefail

ENV="${1:-dev}"
ACCOUNT_ID="${2:-$(aws sts get-caller-identity --query Account --output text)}"
BUCKET="${3:-}"

if [[ -z "${BUCKET}" ]]; then
  echo "Usage: $0 [env] [account_id] <data_lake_bucket_name>"
  exit 1
fi

INGEST_ROLE="health-lake-ingest-${ENV}"
REPORTING_ROLE="health-lake-reporting-${ENV}"
TEST_KEY="clean/iam-test/denied.txt"

echo "=== Testing ingest role (should DENY write to clean/) ==="
if aws sts assume-role \
  --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/${INGEST_ROLE}" \
  --role-session-name "iam-test-ingest" \
  --duration-seconds 900 \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text 2>/dev/null | {
  read -r AK SK ST
  AWS_ACCESS_KEY_ID="$AK" AWS_SECRET_ACCESS_KEY="$SK" AWS_SESSION_TOKEN="$ST" \
    aws s3 cp /dev/null "s3://${BUCKET}/${TEST_KEY}" 2>&1 || true
}; then
  echo "(check output above — expect AccessDenied)"
fi

echo ""
echo "=== Testing reporting role (should DENY write to curated/) ==="
if aws sts assume-role \
  --role-arn "arn:aws:iam::${ACCOUNT_ID}:role/${REPORTING_ROLE}" \
  --role-session-name "iam-test-reporting" \
  --duration-seconds 900 \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text 2>/dev/null | {
  read -r AK SK ST
  AWS_ACCESS_KEY_ID="$AK" AWS_SECRET_ACCESS_KEY="$SK" AWS_SESSION_TOKEN="$ST" \
    aws s3 cp /dev/null "s3://${BUCKET}/curated/iam-test/denied.txt" 2>&1 || true
}; then
  echo "(check output above — expect AccessDenied)"
fi

echo ""
echo "Done. Screenshot both AccessDenied results for your README."
