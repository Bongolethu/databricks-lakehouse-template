---
name: "📐 Governance Policy & Security Change"
about: Declare or modify access control lists, dynamic row-filters, column masking, or data retention policies.
title: "[GOVERNANCE-POLICY]: <Area/Table Affected>"
labels: ["solution-architect", "unity-catalog", "security"]
assignees: ""
---

## 📐 PART 1: COMPLIANCE & SECURITY DEMAND

### 1.1 Regulatory / Governance Context
- **Compliance Driver:** [ ] GDPR / Privacy | [ ] HIPPA / Medical | [ ] PCI / Financial | [ ] Internal Data Strategy
- **Risk Classification:** [ ] Critical (Direct PII/Financial leakage risk) | [ ] High | [ ] Medium
- **Data Subject Domain:** (e.g., Customer contact details, employee salary data)

### 1.2 Access Scope Target
- **Target Target Boundary:** `catalog.schema.table_or_volume`
- **Resource Scope:** [ ] Full Catalog | [ ] Specific Schema Layer | [ ] Individual Table | [ ] Specified Volume Directory

---

## 🔒 PART 2: CONTROL LAYER DECLARATION

### 2.1 Identity & Access Privileges (ACLs)
Specify which user group personas receive or lose operational capability:

| User Group Persona | Action | Granted Privileges |
| :--- | :--- | :--- |
| `data_developers` | [ ] GRANT | [ ] USE_CATALOG | [ ] USE_SCHEMA | [ ] SELECT | [ ] MODIFY |
| `bi_developers` | [ ] GRANT | [ ] USE_CATALOG | [ ] USE_SCHEMA | [ ] SELECT |
| `business_analysts` | [ ] GRANT | [ ] USE_CATALOG | [ ] USE_SCHEMA | [ ] SELECT |
| `service_principals_prod`| [ ] GRANT | [ ] ALL PRIVILEGES |

---

### 2.2 Dynamic Column Masking (PII / Structural Obfuscation)
- **Column Target(s):** 
- **Masking Logic Specification:** Define the SQL conditional rule to redact values based on user persona context.

```sql
-- Target Rule Function Template:
CREATE OR REPLACE FUNCTION main.governance.<mask_function_name>(val STRING)
RETURN CASE 
  WHEN is_account_group_member('security_admins') THEN val 
  WHEN is_account_group_member('hr_admins') THEN val 
  ELSE 'REDACTED-CLASSIFIED' 
END;