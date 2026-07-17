---
name: "🧪 AI Model / Prompt Evaluation Failure"
about: Log an automated evaluation test failure, regression drop, hallucination anomaly, or semantic drift violation.
title: "[LLM-EVAL-FAIL]: <Component/Prompt Name> - <Type of Failure>"
labels: ["qa-tester", "data-developer", "claude-eval"]
assignees: ""
---

## 🧪 PART 1: EVALUATION RUN INFRASTRUCTURE

### 1.1 Run Telemetry & Environment
- **Failed Test ID / Workflow Run URL:** 
- **Target Prompt Template File:** `src/prompts/<path_to_template>.md`
- **Model Endpoint Version:** [ ] Claude 3.5 Sonnet | [ ] Claude 3 Opus | [ ] Databricks Foundation Model API
- **Execution Target Boundary:** [ ] CI Build Stage (GitHub Actions) | [ ] Live Staging Monitor | [ ] Production Human-in-the-Loop Quarantine

### 1.2 Failure Classification
- [ ] **Functional Crash:** Code execution failed (Syntax error, API timeout, rate limits hit).
- [ ] **Semantic Drift / Quality Drop:** System evaluation score fell below the acceptable quality boundary.
- [ ] **Hallucination / Factuality Violation:** Claude output contradicted established facts within the Gold reference table.
- [ ] **Guardrail / PII Breach:** Model output leaked sensitive, unmasked fields or violated behavioral restrictions.

---

## 📊 PART 2: METRIC DRIFT & ANOMALY BREAKDOWN

### 2.1 Quantitative Scoring Discrepancies
Provide the evaluation framework metrics (e.g., LLM-as-a-judge score, ROUGE, BLEU, or Cosine Similarity metrics):

| Metric Variant | Quality Threshold | Observed Score | Failure Status |
| :--- | :--- | :--- | :--- |
| **Context Relevance** | $\ge 0.85$ | `0.62` | ❌ Critical Drop |
| **Groundedness Score**| $\ge 0.90$ | `0.71` | ❌ Grounding Breach |
| **Toxic/Bias Filter** | `0.00` | `0.00` |  Pass |

### 2.2 Reproducible Evidence (Golden Test Sample Match)
Paste the exact scenario input data extracted from `triage-golden-samples.json` or the runtime log that triggered the failure.

* **Expected Reference Answer / Business Expectation:**
> [Insert what the BA approved output looks like]

* **Claude Actual Response Payload:**
> [Insert the failed response generated during the pipeline test]

---

## 🚀 PART 3: REMEDIATION TRACKING
*To be filled out by the Data Developer / Prompt Engineer during resolution.*

- [ ] **Few-Shot Update Required:** [ ] Yes | [ ] No (Update target validation rules inside `FEW-SHOT-EXAMPLES/`)
- [ ] **System Prompt Isolation Shift:** [ ] Yes | [ ] No (Modify core behavioral layout boundaries)
- [ ] **RAG Gold-Layer Data Patch:** [ ] Yes | [ ] No (Address chunk size or embedding fragmentation issue)