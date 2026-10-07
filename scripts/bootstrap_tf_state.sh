#!/usr/bin/env bash
# One-time bootstrap: create the Terraform remote state bucket.
# Run BEFORE terraform init in envs/dev or envs/prod.
set -euo pipefail

ACCOUNT_ID="${1:-$(aws sts get-caller-identity --query Account --output text)}"
OWNER="${2:-health-lake}"
REGION="${3:-af-south-1}"
STATE_BUCKET="${OWNER}-tfstate-${ACCOUNT_ID}"

echo "Creating state bucket: ${STATE_BUCKET} in ${REGION}"

aws s3api create-bucket \
  --bucket "${STATE_BUCKET}" \
  --region "${REGION}" \
  --create-bucket-configuration "LocationConstraint=${REGION}"

aws s3api put-public-access-block \
  --bucket "${STATE_BUCKET}" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

aws s3api put-bucket-versioning \
  --bucket "${STATE_BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${STATE_BUCKET}" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "Done. Update terraform/envs/*/backend.tf with bucket: ${STATE_BUCKET}"
