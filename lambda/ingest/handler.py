"""Download OWID vaccination CSV and write to S3 raw zone."""

from __future__ import annotations

import os
import urllib.request
from datetime import date

import boto3

OWID_URL = (
    "https://ourworldindata.org/grapher/vaccination-coverage-who-unicef.csv"
    "?v=1&csvType=full&useColumnShortNames=false"
    "&antigen=comparison&metric=coverage"
)
SOURCE = "owid"
FILENAME = "vaccination_coverage.csv"
USER_AGENT = "Health-Lake-Ingest/1.0 (portfolio project)"


def handler(event, context):
    bucket = os.environ["DATA_LAKE_BUCKET"]
    ingest_date = event.get("ingest_date") or date.today().isoformat()
    key = f"raw/{SOURCE}/ingest_date={ingest_date}/{FILENAME}"

    req = urllib.request.Request(OWID_URL, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=120) as response:
        body = response.read()

    s3 = boto3.client("s3")
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=body,
        ContentType="text/csv",
        ServerSideEncryption="AES256",
    )

    return {
        "statusCode": 200,
        "bucket": bucket,
        "key": key,
        "bytes": len(body),
        "ingest_date": ingest_date,
    }
