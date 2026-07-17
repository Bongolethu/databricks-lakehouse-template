---
name: "📋 Data Contract & Schema Request"
about: Initiate or modify a schema contract for Databricks Unity Catalog (BA & TA joint delivery).
title: "[DATA-CONTRACT]: <Subject/Domain Name>"
labels: ["business-analyst", "technical-analyst", "unity-catalog"]
assignees: ""
---

## 📋 PART 1: BUSINESS LOGIC & CONTEXT (Owned by Business Analyst)

### 1.1 Objective & Value Realization
- **Business Use Case Name:** 
- **Downstream AI / LLM Context Layer:** Will this data feed into a Claude AI RAG pipeline, a Genie Space, or a standard BI dashboard?
- **Expected Value Metric:** (e.g., Reduces manual data lookup by 20%, powers customer triage agent classification)

### 1.2 Data Latency & Retention Rules
- **Ingestion Frequency:** [ ] Real-time Streaming | [ ] Hourly Batch | [ ] Daily Batch
- **Data Retention Boundary:** [ ] 30 Days | [ ] 90 Days | [ ] 7 Years / Compliance | [ ] Infinite Audit Trail
- **SLA Threshold:** Max allowable processing delay before alerting business stakeholders (e.g., data must be in Gold within 15 minutes of source creation).

---

## 🔍 PART 2: TECHNICAL SCHEMA CONTRACT (Owned by Technical Analyst)

### 2.1 Target Three-Tier Namespace
- **Catalog:** `main`
- **Target Schema Layer:** [ ] `bronze` | [ ] `silver` | [ ] `gold`
- **Target Table Identifier:** `main.<layer>.<table_name>`

### 2.2 Schema Definitions & Constraints
Define columns, strict structural typings, nullability constraints, and privacy layers for Unity Catalog enforcement.

| Column Physical Name | Business Description | Target Data Type | Primary/Foreign Key | Is Nullable? | Security Tag / Masking? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `transaction_id` | Unique ID for financial tracking | `STRING` | PRIMARY KEY | No | None |
| `customer_id` | ID referencing customer profile | `STRING` | FK (main.gold.customers)| No | None |
| `email_address` | Primary customer contact info | `STRING` | None | Yes | `PII` (Requires `email_mask`) |
| `raw_input_text` | Semantic interaction log for Claude | `STRING` | None | Yes | `Unstructured` (Scan for PII) |
| `created_timestamp`| Ingestion timestamp in UTC | `TIMESTAMP` | None | No | None |

### 2.3 Data Validation Rules (Delta Live Table Expectations)
Define the validation constraints that must run automatically in the data pipeline before moving data out of Bronze:
1. **Rule `valid_transaction_id`:** `CRITICAL` -> Fail pipeline if `transaction_id IS NULL`.
2. **Rule `valid_email_format`:** `ALERT / QUARANTINE` -> If email doesn't match regex `'%@%.%'`, route row to `quarantine` table for automated cleanup loops.

---

## 🚀 PART 3: DEVELOPMENT & QA ACCEPTANCE CRITERIA
*This section is utilized by the Developers and Testers during review meetings.*

- [ ] **Data Contract Signed:** BA and TA have validated column definitions.
- [ ] **Infrastructure Readiness:** Storage external locations have been provisioned via Terraform.
- [ ] **Security Alignment:** Architect has confirmed the specific masking policies for columns flagged with security tags.