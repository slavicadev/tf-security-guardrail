# 🛡️ AI-Powered DevSecOps Terraform Security Guardrail

An automated continuous compliance gatekeeper built inside **GitHub Actions** that intercepts Infrastructure as Code (IaC) misconfigurations prior to deployment using Generative AI and structured schemas.

---

## 🚀 Overview

In modern cloud environments, small mistakes in Infrastructure as Code (like leaving an S3 bucket public or an SSH port open to the world) can lead to catastrophic data breaches. 

This repository implements a **Shift-Left DevSecOps approach**. Whenever code is pushed or a Pull Request is opened, a CI/CD pipeline compiles an offline Terraform execution plan, converts it into structured machine-readable JSON, and routes it to an **AI Security Architect (Gemini 2.5 Flash)**. 

Utilizing strict deterministic **Pydantic validation schemas**, the AI evaluates the plan. If critical security flaws are detected, the pipeline automatically crashes (`exit 1`), blocking insecure deployments from hitting production and providing actionable, code-level remediation steps directly in the pipeline logs.

---

## 🛠️ Key Features

* **Shift-Left Security Compliance:** Validates security configurations natively during the code review stage of the Software Development Life Cycle (SDLC).
* **Deterministic AI Responses:** Uses Structured Outputs (JSON Schema enforcement via Pydantic) to force the LLM to return consistent, parseable, and reliable analytical datasets.
* **Cost-Efficient Planning:** Runs entirely offline using dummy credential targets, ensuring no cloud cloud API rate limits are hit during the planning phase.
* **CI/CD Gatekeeping:** Leverages POSIX exit signals to hard-abort builds upon identifying `CRITICAL` or `WARNING` vulnerabilities.

---

## 🧰 Tech Stack

* **Infrastructure Automation:** HashiCorp Terraform (AWS Provider)
* **AI Orchestration:** Google GenAI SDK (Gemini 2.5 Flash)
* **Data Validation & Parsing:** Python 3.11, Pydantic v2
* **CI/CD Platform:** GitHub Actions

---

## 📂 Repository Structure

* `.github/workflows/security-gate.yml` — The GitHub Actions automation workflow pipeline.
* `main.tf` — The core infrastructure setup containing the evaluated cloud resources.
* `scan_plan.py` — The Python audit engine that loads the plan, orchestrates the AI request, and enforces the pipeline gate.
* `.gitignore` — Built to safeguard sensitive local files (`plan.json`, binary configurations, python virtual environments) from accidental source control tracking.

---

## 📊 Pipeline Behavior & SRE Impact

### ❌ The Catch (Security Flaw Detected)
When insecure configurations are committed (e.g., `cidr_blocks = ["0.0.0.0/0"]` on port 22), the pipeline captures the violation:

```text
==================================================
🛡️  DEVSECOPS SECURITY VERDICT: FAIL
==================================================
Summary: Critical security vulnerabilities detected. The plan includes an AWS Security Group allowing global SSH access (0.0.0.0/0).

⚠️  Found 1 Security Vulnerabilities:

  [1] Resource: aws_security_group.allow_ssh_global
      Severity: CRITICAL
      Vulnerability: Overly permissive networking rule: The security group permits inbound SSH from 0.0.0.0/0.
      Fix: Restrict the ingress rule for port 22 to specific, trusted internal corporate IP spaces (e.g., 10.0.0.0/16).

❌ Deployment Blocked: Critical security flaws must be resolved.

==================================================
🛡️  DEVSECOPS SECURITY VERDICT: PASS
==================================================
Summary: All infrastructure changes comply with enterprise compliance guidelines.
✅ No critical security violations detected.
🚀 Deployment Approved: Infrastructure compliant.

## 🛠️ Local Development & Replication

Follow these steps to run the AI security scanner locally on your workstation to test infrastructure changes offline before pushing them to GitHub.

### 1. Clone the Repository
```bash
git clone 
cd tf-security-guardrail

### 2. Set Up Python Virtual Environment
python3 -m venv venv
source venv/bin/activate
pip install google-genai pydantic

### 3. Generate the Offline Terraform JSON Plan
terraform init
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > plan.json

### 4. Run the AI Security Scanner
export GEMINI_API_KEY="your_actual_api_key_here"
python scan_plan.py
