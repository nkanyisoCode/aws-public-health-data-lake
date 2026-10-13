#!/usr/bin/env bash
# Manually invoke the ingest Lambda (or upload a local CSV to raw/).
set -euo pipefail

ENV="${1:-dev}"
INGEST_DATE="${2:-$(date +%Y-%m-%d)}"
BUCKET="${3:-}"

if [[ -z "${BUCKET}" ]]; then
  echo "Usage: $0 [env] [ingest_date] <data_lake_bucket_name>"
  exit 1
fi

FUNC="health-lake-ingest-${ENV}"

echo "Invoking ${FUNC} for ingest_date=${INGEST_DATE}..."
aws lambda invoke \
  --function-name "${FUNC}" \
  --payload "{\"ingest_date\": \"${INGEST_DATE}\"}" \
  --cli-binary-format raw-in-base64-out \
  /tmp/ingest-response.json

cat /tmp/ingest-response.json
echo ""
echo "New raw file should trigger clean Lambda via S3 event notification."
echo "Check: aws s3 ls s3://${BUCKET}/raw/owid/ingest_date=${INGEST_DATE}/"
