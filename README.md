# 🔐 SecureWebOps

> A production-grade DevSecOps pipeline on AWS — built to demonstrate real-world cloud security engineering practice, not tutorial-level setup.

![Phase](https://img.shields.io/badge/Phase-1%20Complete-3fb950?style=flat-square)
![AWS](https://img.shields.io/badge/Cloud-AWS%20eu--west--1-FF9900?style=flat-square&logo=amazonaws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=flat-square&logo=terraform)
![Security](https://img.shields.io/badge/Security-8%20Controls-58a6ff?style=flat-square)

---

## What This Project Is

SecureWebOps is a hardened, automated deployment pipeline for a containerised web application on AWS. Every component is built with security as the primary design constraint — not bolted on afterward.

The project demonstrates how a Cloud Security Engineer approaches infrastructure: by identifying attack vectors at each layer and implementing specific, named controls to mitigate them.

---

## Security Controls Implemented

| Control | Implementation | Threat Mitigated |
|---|---|---|
| No static AWS credentials | GitHub Actions OIDC federation | Credential theft via secrets exposure |
| Branch-restricted pipeline | OIDC trust scoped to `main` only | Lateral movement from feature branches |
| IMDSv2 enforced | `http_tokens = "required"` | SSRF-based metadata credential theft |
| No SSH access | AWS SSM Session Manager only | Brute force, exposed port 22 |
| Encrypted EBS volume | `encrypted = true` on root block device | Data exposure from volume snapshot theft |
| Least-privilege IAM | Scoped pipeline policy, explicit actions only | Privilege escalation via over-permissioned roles |
| Non-root container | Dockerfile user: appuser (UID 1001) | Container escape privilege escalation |
| Setuid/setgid removal | `chmod a-s` on all binaries | In-container privilege escalation |

---

## Architecture — Phase 1

```
GitHub Repository
       │
       │  Push to main branch
       ▼
GitHub Actions Pipeline
       │
       ├── Checkov      → IaC security scanning (Terraform)
       ├── Bandit       → Python SAST
       ├── OWASP ZAP   → DAST against live endpoint
       │
       │  OIDC → AssumeRoleWithWebIdentity (no static keys)
       ▼
AWS (eu-west-1 / Ireland)
       │
       ├── VPC (10.0.0.0/16)
       │     └── Public Subnet (10.0.1.0/24)
       │           └── EC2 t3.micro (Amazon Linux 2023)
       │                 ├── IMDSv2 enforced
       │                 ├── Encrypted EBS (gp3, 20GB)
       │                 ├── SSM access only (no SSH)
       │                 └── Elastic IP
       │
       ├── Security Group (ports 80/443 only — no 22)
       ├── IAM OIDC Role (branch-restricted trust policy)
       └── S3 + DynamoDB (Terraform remote state + locking)
```

---

## Tech Stack

**Infrastructure as Code:** Terraform ≥ 1.5.0
**Cloud Provider:** AWS (eu-west-1)
**CI/CD:** GitHub Actions with OIDC authentication
**Container Runtime:** Docker (multi-stage, hardened)
**Web Server:** nginx 1.25-alpine (non-root)
**IaC Security Scanning:** Checkov
**SAST:** Bandit (Python)
**DAST:** OWASP ZAP
**Remote State:** S3 + DynamoDB locking
**Instance Access:** AWS Systems Manager Session Manager

---

## Repository Structure

```
securewebops/
├── terraform/
│   ├── main.tf          # Provider config, S3 backend, resource tags
│   ├── ec2.tf           # EC2 instance, IMDSv2, encrypted EBS, EIP
│   ├── iam.tf           # OIDC role, least-privilege policy, EC2 profile
│   ├── vpc.tf           # VPC, subnet, IGW, route tables, security groups
│   ├── variables.tf     # Input variables with validation
│   └── outputs.tf       # Stack outputs including OIDC role ARN
├── app/
│   ├── index.html       # Demo application showing security control status
│   ├── Dockerfile       # Multi-stage, hardened, non-root nginx container
│   └── nginx.conf       # Hardened nginx configuration
└── .github/
    └── workflows/
        └── deploy.yml   # CI/CD pipeline (Phase 2 — in progress)
```

---

## Key Design Decisions

**Why OIDC instead of AWS access keys?**
Static credentials stored as GitHub secrets are a common breach vector. OIDC federation means the pipeline authenticates via short-lived web identity tokens — no long-lived credentials exist anywhere.

**Why SSM instead of SSH?**
Port 22 is one of the most scanned ports on the internet. SSM Session Manager provides audited, authenticated shell access through the AWS control plane — no inbound port required, no key pairs to manage.

**Why IMDSv2?**
IMDSv1 is vulnerable to SSRF attacks where a compromised application can request `http://169.254.169.254/latest/meta-data/iam/security-credentials/` and steal instance credentials. IMDSv2 requires a session token obtained via a PUT request — SSRF attacks cannot replicate this.

**Why multi-stage Docker builds?**
Build tools, compilers, and package managers dramatically expand the attack surface of a container image. Multi-stage builds ensure only the compiled output reaches the production image.

---

## Roadmap

### ✅ Phase 1 — Hardened Deployment Pipeline (Complete)
Terraform IaC, GitHub Actions CI/CD, Checkov, Bandit, OWASP ZAP, IMDSv2, OIDC auth, encrypted EBS, non-root container, SSM access

### 🔄 Phase 2 — Runtime Security & Threat Detection (In Progress)
- AWS GuardDuty for threat detection and anomaly alerting
- AWS Security Hub for centralised security findings
- CloudTrail with S3 logging and integrity validation
- VPC Flow Logs for network traffic analysis
- CloudWatch alerting on suspicious IAM and API activity

### 📋 Phase 3 — IAM Hardening & Secrets Management
- AWS Secrets Manager integration — eliminate environment variable secrets
- IAM Access Analyzer for policy validation and external access detection
- Service Control Policies (SCPs) at AWS Organizations level
- Automated IAM credential rotation
- Privileged access review automation

### 📋 Phase 4 — Compliance as Code
- AWS Config rules mapped to CIS AWS Foundations Benchmark
- Automated compliance reporting
- Security posture drift detection and alerting
- HIPAA and PCI DSS control mapping documentation

### 📋 Phase 5 — Container Security & Kubernetes
- Migration from EC2 to Amazon EKS
- Trivy container image vulnerability scanning in CI/CD
- Kubernetes RBAC and network policies
- Falco runtime threat detection
- OPA/Gatekeeper policy enforcement

---

## About

Built by **Moses Daniel** — Cloud Security Engineer based in Abuja, Nigeria.

- 🔗 [LinkedIn](https://linkedin.com/in/moses-daniel-a8a80861)
- 💻 [GitHub](https://github.com/MODAN07)
- 🎓 Google Professional Cloud Security Engineer (PCSE)

---

*This project is actively developed. Each phase adds a new layer of the cloud security engineering stack — from pipeline security through runtime detection, IAM hardening, compliance automation, and container security.*
