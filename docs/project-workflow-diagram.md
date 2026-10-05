# Project Workflow & Planning Diagrams

> **UML diagrams (Use Case, Sequence, Class, Component, Deployment, Activity, State, Gantt):**  
> See **[docs/diagrams/](diagrams/)** — PlantUML source files you can export to PNG/SVG.

## 1. Runtime data pipeline (AWS)

What the system does once deployed:

```mermaid
flowchart TB
    subgraph Public["Public internet"]
        OWID["OWID vaccination CSV"]
    end

    subgraph Schedule["Automation"]
        EB["EventBridge<br/>weekly schedule"]
    end

    subgraph Ingest["Ingest layer — no VPC"]
        IL["Ingest Lambda"]
    end

    subgraph Storage["S3 Data Lake"]
        RAW["raw/<br/>dated CSV snapshots"]
        CLEAN["clean/<br/>Parquet partitions"]
        CURATED["curated/<br/>star schema"]
        QUAR["quarantine/<br/>rejected rows"]
        ATH["athena-results/"]
    end

    subgraph Process["Processing"]
        CL["Clean Lambda<br/>S3 event trigger"]
        GC["Glue Crawler<br/>on-demand"]
    end

    subgraph Query["Analytics"]
        GDC["Glue Data Catalog"]
        ATHENA["Athena SQL"]
    end

    subgraph Ops["Monitoring & security"]
        CW["CloudWatch alarms"]
        SNS["SNS email alerts"]
        CT["CloudTrail + S3 access logs"]
        BUD["AWS Budget alert"]
    end

    OWID --> IL
    EB --> IL
    IL --> RAW
    RAW -->|"ObjectCreated .csv"| CL
    CL --> CLEAN
    CL --> CURATED
    CL --> QUAR
    CL --> GC
    GC --> GDC
    CLEAN --> GDC
    CURATED --> GDC
    GDC --> ATHENA
    ATHENA --> ATH

    IL -.->|errors| CW
    CL -.->|errors| CW
    CW --> SNS
    Storage -.-> CT
    BUD -.-> SNS
```

---

## 2. Fourteen-day GitHub push workflow

How you build and push the repo (no AWS required until after Day 14):

```mermaid
flowchart LR
    subgraph W1["Week 1 — Code & docs"]
        D1["Day 1<br/>README · gitignore · checkov"]
        D2["Day 2<br/>architecture · security docs"]
        D3["Day 3<br/>cost · runbook"]
        D4["Day 4<br/>bootstrap scripts"]
        D5["Day 5<br/>ingest Lambda"]
        D6["Day 6<br/>clean Lambda"]
        D7["Day 7<br/>helper scripts"]
        D8["Day 8<br/>Athena SQL"]
    end

    subgraph W2["Week 2 — Terraform & CI"]
        D9["Day 9<br/>S3 data lake module"]
        D10["Day 10<br/>ingestion module"]
        D11["Day 11<br/>analytics module"]
        D12["Day 12<br/>security module"]
        D13["Day 13<br/>dev env + VPC/RDS"]
        D14["Day 14<br/>CI/CD · prod · polish"]
    end

    subgraph After["After Day 14"]
        AWS["Create AWS account"]
        DEPLOY["terraform apply"]
        PROVE["Athena query + IAM tests"]
    end

    D1 --> D2 --> D3 --> D4 --> D5 --> D6 --> D7 --> D8
    D8 --> D9 --> D10 --> D11 --> D12 --> D13 --> D14
    D14 --> AWS --> DEPLOY --> PROVE
```

---

## 3. Repository structure (target end state)

```mermaid
flowchart TB
    ROOT["aws-public-health-data-lake/"]

    ROOT --> DOCS["docs/"]
    ROOT --> LAMBDA["lambda/"]
    ROOT --> SCRIPTS["scripts/"]
    ROOT --> SQL["sql/"]
    ROOT --> TF["terraform/"]
    ROOT --> GH[".github/workflows/"]

    DOCS --> D1["architecture.md"]
    DOCS --> D2["security-decisions.md"]
    DOCS --> D3["cost-estimate.md"]
    DOCS --> D4["runbook.md"]

    LAMBDA --> LI["ingest/handler.py"]
    LAMBDA --> LC["clean/handler.py"]

    TF --> MOD["modules/"]
    TF --> ENV["envs/dev · prod"]

    MOD --> M1["data_lake"]
    MOD --> M2["ingestion"]
    MOD --> M3["analytics"]
    MOD --> M4["security"]
    MOD --> M5["network"]
    MOD --> M6["warehouse"]
    MOD --> M7["cicd"]
```

---

## 4. IAM roles and S3 zones

```mermaid
flowchart LR
    subgraph Roles["IAM roles"]
        R1["ingest role<br/>write raw/ only"]
        R2["clean role<br/>read raw/ · write clean/ curated/ quarantine/"]
        R3["reporting role<br/>read clean/ curated/ · Athena"]
    end

    subgraph Zones["S3 prefixes"]
        Z1["raw/"]
        Z2["clean/"]
        Z3["curated/"]
        Z4["quarantine/"]
    end

    R1 -->|PutObject| Z1
    R2 -->|GetObject| Z1
    R2 -->|PutObject| Z2
    R2 -->|PutObject| Z3
    R2 -->|PutObject| Z4
    R3 -->|GetObject| Z2
    R3 -->|GetObject| Z3
```

---

## Viewing these diagrams

- **GitHub:** Mermaid renders automatically in markdown on github.com
- **VS Code:** Install "Markdown Preview Mermaid Support"
- **Export PNG:** Paste into [mermaid.live](https://mermaid.live) → Export
