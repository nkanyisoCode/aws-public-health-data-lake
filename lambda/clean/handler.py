"""Clean raw OWID CSV from S3 and write partitioned Parquet to clean/ zone."""

from __future__ import annotations

import io
import json
import os
import re
from datetime import datetime

import boto3
import pandas as pd

INDICATOR_COLUMNS = {
    "Measles, first dose (MCV1)": ("measles_mcv1", "Measles (MCV1)", "vaccination", "%"),
    "Diphtheria/tetanus/pertussis (DTP3)": ("dtp3", "DTP3", "vaccination", "%"),
    "Polio (Pol3)": ("polio_pol3", "Polio (Pol3)", "vaccination", "%"),
    "Hepatitis B (HepB3)": ("hepb3", "Hepatitis B (HepB3)", "vaccination", "%"),
}

VALUE_MIN, VALUE_MAX = 0.0, 100.0
s3 = boto3.client("s3")
glue = boto3.client("glue")


def _parse_s3_event(event: dict) -> tuple[str, str]:
    record = event["Records"][0]
    bucket = record["s3"]["bucket"]["name"]
    key = record["s3"]["object"]["key"]
    return bucket, key


def _read_wide_vaccination(df: pd.DataFrame) -> pd.DataFrame:
    df = df.rename(columns={"Entity": "region_name", "Code": "iso_code", "Year": "year"})
    df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")
    value_cols = [c for c in df.columns if c in INDICATOR_COLUMNS]
    long_df = df.melt(
        id_vars=["region_name", "iso_code", "year"],
        value_vars=value_cols,
        var_name="indicator_source_col",
        value_name="value",
    )
    long_df["value"] = pd.to_numeric(long_df["value"], errors="coerce")
    return long_df


def _apply_indicator_metadata(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for _, row in df.iterrows():
        meta = INDICATOR_COLUMNS.get(row["indicator_source_col"])
        if not meta:
            continue
        indicator_code, indicator_name, category, unit = meta
        rows.append(
            {
                **row.to_dict(),
                "indicator_code": indicator_code,
                "indicator_name": indicator_name,
                "indicator_category": category,
                "indicator_unit": unit,
            }
        )
    return pd.DataFrame(rows)


def _region_type(iso_code) -> str:
    if not iso_code or pd.isna(iso_code):
        return "unknown"
    code = str(iso_code).strip()
    if code.startswith("OWID_"):
        return "aggregate"
    if len(code) == 3:
        return "country"
    return "other"


def _standardise_regions(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["region_name"] = df["region_name"].str.strip()
    df["iso_code"] = df["iso_code"].astype(str).str.strip().replace({"nan": None, "None": None})
    df["region_type"] = df["iso_code"].apply(_region_type)
    df["region_key"] = df["iso_code"].fillna(df["region_name"].str.lower().str.replace(" ", "_"))
    return df


def _validate_rows(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    records, rejected = [], []
    for idx, row in df.iterrows():
        reasons = []
        if pd.isna(row["year"]) or row["year"] < 1980 or row["year"] > datetime.utcnow().year + 1:
            reasons.append("invalid_year")
        if pd.isna(row["region_name"]) or not str(row["region_name"]).strip():
            reasons.append("missing_region")
        if pd.notna(row["value"]) and (row["value"] < VALUE_MIN or row["value"] > VALUE_MAX):
            reasons.append("value_out_of_range")
        if reasons:
            rejected.append(
                {
                    "region_name": row.get("region_name"),
                    "year": row.get("year"),
                    "indicator_code": row.get("indicator_code"),
                    "value": row.get("value"),
                    "reject_reason": "|".join(reasons),
                }
            )
        else:
            records.append(row)
    return pd.DataFrame(records), pd.DataFrame(rejected)


def _write_parquet_partition(df: pd.DataFrame, bucket: str, indicator: str, year: int) -> str:
    subset = df[(df["indicator_code"] == indicator) & (df["year"] == year)]
    if subset.empty:
        return ""
    buf = io.BytesIO()
    subset.to_parquet(buf, index=False, engine="pyarrow")
    key = f"clean/{indicator}/year={year}/part-0000.parquet"
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=buf.getvalue(),
        ServerSideEncryption="AES256",
    )
    return key


def _write_curated(clean_df: pd.DataFrame, bucket: str) -> list[str]:
    """Build star-schema extracts in curated/ zone."""
    keys = []
    regions = (
        clean_df[["region_key", "region_name", "iso_code", "region_type"]]
        .drop_duplicates(subset=["region_key"])
        .sort_values("region_name")
    )
    buf = io.BytesIO()
    regions.to_parquet(buf, index=False, engine="pyarrow")
    dim_key = "curated/dim_region/part-0000.parquet"
    s3.put_object(Bucket=bucket, Key=dim_key, Body=buf.getvalue(), ServerSideEncryption="AES256")
    keys.append(dim_key)

    fact_cols = [
        "region_key", "year", "indicator_code", "indicator_name",
        "indicator_category", "value", "is_missing", "is_revised", "is_estimated",
    ]
    buf = io.BytesIO()
    clean_df[fact_cols].to_parquet(buf, index=False, engine="pyarrow")
    fact_key = "curated/fact_health_indicator/part-0000.parquet"
    s3.put_object(Bucket=bucket, Key=fact_key, Body=buf.getvalue(), ServerSideEncryption="AES256")
    keys.append(fact_key)
    return keys


def _quarantine_rejected(rejected: pd.DataFrame, bucket: str, ingest_key: str) -> str | None:
    if rejected.empty:
        return None
    match = re.search(r"ingest_date=(\d{4}-\d{2}-\d{2})", ingest_key)
    ingest_date = match.group(1) if match else datetime.utcnow().date().isoformat()
    buf = io.BytesIO()
    rejected.to_parquet(buf, index=False, engine="pyarrow")
    key = f"quarantine/rejected/ingest_date={ingest_date}/part-0000.parquet"
    s3.put_object(Bucket=bucket, Key=key, Body=buf.getvalue(), ServerSideEncryption="AES256")
    return key


def _trigger_glue_crawler(crawler_name: str | None) -> None:
    if not crawler_name:
        return
    try:
        glue.start_crawler(Name=crawler_name)
    except glue.exceptions.CrawlerRunningException:
        pass


def handler(event, context):
    bucket, key = _parse_s3_event(event)
    if not key.startswith("raw/") or not key.endswith(".csv"):
        return {"skipped": True, "reason": "not a raw CSV object", "key": key}

    obj = s3.get_object(Bucket=bucket, Key=key)
    raw_df = pd.read_csv(io.BytesIO(obj["Body"].read()))

    long_df = _read_wide_vaccination(raw_df)
    long_df = _apply_indicator_metadata(long_df)
    long_df = _standardise_regions(long_df)
    long_df["is_missing"] = long_df["value"].isna()
    clean_df, rejected_df = _validate_rows(long_df)
    clean_df["is_revised"] = False
    clean_df["is_estimated"] = clean_df["is_missing"] | clean_df["is_revised"]
    clean_df["loaded_at"] = datetime.utcnow().isoformat()

    parquet_keys = []
    for indicator in clean_df["indicator_code"].dropna().unique():
        for year in clean_df.loc[clean_df["indicator_code"] == indicator, "year"].dropna().unique():
            out_key = _write_parquet_partition(clean_df, bucket, indicator, int(year))
            if out_key:
                parquet_keys.append(out_key)

    curated_keys = _write_curated(clean_df, bucket)
    quarantine_key = _quarantine_rejected(rejected_df, bucket, key)

    crawler_name = os.environ.get("GLUE_CRAWLER_NAME")
    _trigger_glue_crawler(crawler_name)

    stats = {
        "source_key": key,
        "clean_rows": len(clean_df),
        "rejected_rows": len(rejected_df),
        "parquet_partitions": len(parquet_keys),
        "curated_keys": curated_keys,
        "quarantine_key": quarantine_key,
    }
    print(json.dumps(stats))
    return stats
