# [CLIENT_NAME] Website

Static website for [CLIENT_NAME], hosted on AWS S3 + CloudFront.

## Quick Start

```bash
npm ci
```

## Placeholder Convention

All client-specific values use `[square bracket]` syntax throughout `site/`. Find and replace these before deploying:

- `[CLIENT_NAME]` — Business display name
- `[PHONE]` — Phone number
- `[EMAIL]` — Contact email
- `[ADDRESS]` — Street address
- `[CITY]`, `[STATE]`, `[ZIP]` — Location
- `[DOMAIN]` — Production domain

> More placeholders will be added as the site is built. Search `site/` for `[` to find them all.

## Deployment

| Stage | Trigger | URL |
|-------|---------|-----|
| Staging | Push to `main` | CloudFront default URL (auto-generated) |
| Production | Git tag `v*` | Custom domain (configured in `serverless.yml`) |

### Required GitHub Secrets

Set these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM user with S3 + CloudFront + Route53 permissions |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret key |
| `ACM_CERTIFICATE_ARN` | ACM cert ARN in `us-east-1` |
| `HOSTED_ZONE_ID` | Route53 hosted zone ID |

## File Structure

```
.
├── site/                   # Deployable files (synced to S3)
│   ├── index.html
│   ├── 404.html
│   ├── thanks.html
│   ├── robots.txt
│   ├── sitemap.xml
│   ├── css/style.css
│   ├── js/main.js
│   └── assets/
├── serverless.yml          # Serverless Framework + Lift deployment config
├── package.json
├── .github/workflows/      # CI/CD (staging + production)
├── scripts/                # Utility scripts
├── TODO.md                 # Onboarding checklist
├── MEMORY.md               # AI assistant context (design decisions, structure)
└── README.md               # This file
```
