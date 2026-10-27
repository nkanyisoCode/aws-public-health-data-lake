#!/usr/bin/env bash
# Bundle clean Lambda handler with pip dependencies (Amazon Linux / Python 3.12).
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${MODULE_DIR}/../../../lambda/clean"
BUILD_DIR="${MODULE_DIR}/clean_build"

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

python3 -m pip install \
  -r "${SRC_DIR}/requirements.txt" \
  -t "${BUILD_DIR}" \
  --platform manylinux2014_x86_64 \
  --python-version 3.12 \
  --implementation cp \
  --only-binary=:all: \
  --upgrade \
  --no-cache-dir \
  --quiet

cp "${SRC_DIR}/handler.py" "${BUILD_DIR}/"

# Trim package size (boto3 is in the Lambda runtime; drop test trees).
find "${BUILD_DIR}" -type d -name tests -prune -exec rm -rf {} + 2>/dev/null || true
find "${BUILD_DIR}" -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true

echo "Built ${BUILD_DIR} (Terraform archive_file creates clean.zip)"
