# UML & Architecture Diagrams

Professional diagrams for the **Public Health Data Lake on AWS** project.

## Diagram index

| File | Type | Description |
|------|------|-------------|
| [01-use-case.puml](01-use-case.puml) | **UML Use Case** | Actors and system capabilities |
| [02-sequence-ingestion.puml](02-sequence-ingestion.puml) | **UML Sequence** | End-to-end ingest → clean → query flow |
| [03-class-data-model.puml](03-class-data-model.puml) | **UML Class** | Star schema / domain entities |
| [04-component-terraform.puml](04-component-terraform.puml) | **UML Component** | Terraform modules and dependencies |
| [05-deployment-aws.puml](05-deployment-aws.puml) | **UML Deployment** | AWS services and nodes |
| [06-activity-clean-lambda.puml](06-activity-clean-lambda.puml) | **UML Activity** | Clean Lambda processing steps |
| [07-state-s3-object.puml](07-state-s3-object.puml) | **UML State** | S3 object lifecycle through zones |
| [08-14-day-gantt.puml](08-14-day-gantt.puml) | **Gantt** | 2-week push plan timeline |

## How to view / export PNG or SVG

### Option 1 — Online (easiest)

1. Open [https://www.plantuml.com/plantuml/uml/](https://www.plantuml.com/plantuml/uml/)
2. Paste the contents of any `.puml` file
3. Download PNG or SVG

### Option 2 — VS Code

1. Install extension **PlantUML** (jebbs.plantuml)
2. Open a `.puml` file → `Alt+D` to preview → Export

### Option 3 — Command line

```bash
sudo apt install plantuml graphviz
cd docs/diagrams
plantuml -tpng *.puml
plantuml -tsvg *.puml
```

Output files appear next to each `.puml` file.

### Option 4 — GitHub

PlantUML does not render natively on GitHub. Push the `.puml` source files and export PNGs for README:

```bash
plantuml -tpng docs/diagrams/*.puml
git add docs/diagrams/*.png
```

## Recommended for portfolio README

Export these three as PNG and add to README:

1. `02-sequence-ingestion.png` — shows the live pipeline
2. `05-deployment-aws.png` — shows AWS architecture
3. `08-14-day-gantt.png` — shows your 2-week plan
