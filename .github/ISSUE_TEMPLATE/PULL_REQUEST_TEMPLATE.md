<!-- filepath: .github/PULL_REQUEST_TEMPLATE.md -->
# 🚀 Enterprise Lakehouse & AI Prompt Pull Request

## 📝 Change Description
- **Linked Issue / Story ID:** Closes #
- **Impact Radius:** [ ] Unity Catalog Schema | [ ] Cluster Policies | [ ] DLT Ingestion Core | [ ] Claude Prompt / Evaluation Matrix

---

## 👥 Cross-Functional Persona Attestation
*The author must state which sections have been modified. Assigned Code Owners will verify these specific sections during the manual review phase.*

### [ ] 📐 Solution Architect Sign-Off Required
*Applied to changes modifying structural cloud parameters, infrastructure state, or metadata rules.*
- [ ] Confirmed that IAM identities and OIDC federation roles match least-privilege models.
- [ ] Validated that modifications to `infra/terraform/` will not cause accidental deletion of state data.

### [ ] 🔍 Technical Analyst Sign-Off Required
*Applied to changes modifying table layouts, schema definitions, or data typing contracts.*
- [ ] Column names, constraints, and Liquid Clustering configurations perfectly match the downstream data contract.

### [ ] 💻 Data Developer Sign-Off Required
*Applied to changes modifying Delta Live Tables stream logic or analytical pipeline transforms.*
- [ ] Local PySpark transformation scripts have been verified and output logs are attached below.
- [ ] No hardcoded configuration tokens exist; secrets are drawn exclusively via Databricks Secret Scopes.

### [ ] 🧪 QA Tester & Business Analyst Sign-Off Required
*Applied to changes modifying prompt contexts, system intents, or model regression testing datasets.*
- [ ] The automated prompt testing suite execution returned a valid semantic alignment score.
- [ ] The model output payload was inspected manually to guarantee no corporate PII or raw email structures leak during Claude execution.

---

## 🛠️ Pre-Flight Verification Logs
- [ ] The local command execution of `databricks bundle validate` passes cleanly.
- [ ] Unit testing validations successfully ran via `pytest tests/unit/`.

### Delta Live Tables / PyTest Execution Output Snapshot:
```text
[Paste clean pipeline dry-run or local execution trace printouts here]