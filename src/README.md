# Modern Databricks Lakehouse Template (with Claude AI Integrations)

Welcome to the enterprise-grade foundation for the Databricks Lakehouse platform. This repository implements a fully code-driven, persona-isolated data ecosystem managed completely through **Databricks Asset Bundles (DABs)**, **Terraform**, and **Unity Catalog (UC)**.

---

## 🏗️ Repository Architecture

```text
databricks-lakehouse-template/
├── .github/               # GitHub Actions for DABs & Claude Evaluation
├── .databricks/           # Persona configurations and Entitlement Matrices
├── src/                   # DLT Pipelines, Governance Functions, AI syncing
├── infra/                 # Infrastructure as Code (DAB resources & Terraform)
└── tests/                 # Unit, Integration, and Prompt Drift tests