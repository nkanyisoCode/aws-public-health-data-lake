#!/usr/bin/env python3
"""Run the cleaning pipeline locally against S3 (same logic as lambda/clean/handler.py)."""

from __future__ import annotations

import argparse
import io
import os
import sys
from pathlib import Path

import boto3
import pandas as pd

# Re-use Lambda cleaning logic
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lambda" / "clean"))
from handler import (  # noqa: E402
    _apply_indicator_metadata,
    _quarantine_rejected,
    _read_wide_vaccination,
    _standardise_regions,
    _trigger_glue_crawler,
    _validate_rows,
    _write_curated,
    _write_parquet_partition,
)


def clean_from_s3(bucket: str, key: str, region: str, crawler_name: str | None) -> dict:
    s3 = boto3.client("s3", region_name=region)
    obj = s3.get_object(Bucket=bucket, Key=key)
    raw_df = pd.read_csv(io.BytesIO(obj["Body"].read()))

    long_df = _read_wide_vaccination(raw_df)
    long_df = _apply_indicator_metadata(long_df)
    long_df = _standardise_regions(long_df)
    long_df["is_missing"] = long_df["value"].isna()
    clean_df, rejected_df = _validate_rows(long_df)
    clean_df["is_revised"] = False
    clean_df["is_estimated"] = clean_df["is_missing"] | clean_df["is_revised"]

    parquet_keys = []
    for indicator in clean_df["indicator_code"].dropna().unique():
        years = clean_df.loc[clean_df["indicator_code"] == indicator, "year"].dropna().unique()
        for year in years:
            out_key = _write_parquet_partition(clean_df, bucket, indicator, int(year))
            if out_key:
                parquet_keys.append(out_key)

    curated_keys = _write_curated(clean_df, bucket)
    quarantine_key = _quarantine_rejected(rejected_df, bucket, key)
    _trigger_glue_crawler(crawler_name)

    return {
        "source_key": key,
        "clean_rows": len(clean_df),
        "rejected_rows": len(rejected_df),
        "parquet_partitions": len(parquet_keys),
        "curated_keys": curated_keys,
        "quarantine_key": quarantine_key,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Clean raw CSV in S3 and write Parquet partitions.")
    parser.add_argument("--bucket", default=os.environ.get("DATA_LAKE_BUCKET"))
    parser.add_argument("--key", required=True, help="S3 key, e.g. raw/owid/ingest_date=2026-10-05/vaccination_coverage.csv")
    parser.add_argument("--region", default=os.environ.get("AWS_REGION", "af-south-1"))
    parser.add_argument("--crawler", default=os.environ.get("GLUE_CRAWLER_NAME"))
    args = parser.parse_args()

    if not args.bucket:
        sys.exit("Set DATA_LAKE_BUCKET or pass --bucket")

    stats = clean_from_s3(args.bucket, args.key, args.region, args.crawler)
    print(stats)


if __name__ == "__main__":
    main()
