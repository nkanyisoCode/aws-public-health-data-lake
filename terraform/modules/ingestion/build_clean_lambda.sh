#!/usr/bin/env bash
# Bundle clean Lambda handler with pip dependencies (Amazon Linux / Python 3.12).
set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${MODULE_DIR}/../../../lambda/clean"
BUILD_DIR="${MODULE_DIR}/clean_build"
OUT_ZIP="${MODULE_DIR}/clean.zip"

rm -rf "${BUILD_DIR}" "${OUT_ZIP}"
mkdir -p "${BUILD_DIR}"

python3 -m pip install \
  -r "${SRC_DIR}/requirements.txt" \
  -t "${BUILD_DIR}" \
  --platform manylinux2014_x86_64 \
  --python-version 3.12 \
  --implementation cp \
  --only-binary=:all: \
  --upgrade \
  --quiet

cp "${SRC_DIR}/handler.py" "${BUILD_DIR}/"

(
  cd "${BUILD_DIR}"
  zip -r9 "${OUT_ZIP}" . -x '*.pyc' -x '__pycache__/*' >/dev/null
)

echo "Built ${OUT_ZIP}"
