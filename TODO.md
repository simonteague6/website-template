# TODO — Website Template

Onboarding checklist. Check off each item when converting this template into a live client site.

---

## 1. Repo Setup

- [ ] Clone this template into a new repo: `git clone git@github.com:simonteague6/website-template.git [client-name]`
- [ ] Create a new empty repo on GitHub for the client
- [ ] Update remote: `git remote set-url origin git@github.com:simonteague6/[client-name].git`
- [ ] Push to the new repo: `git push -u origin main`

---

## 2. Rename Everything

- [ ] **`serverless.yml`** — change `service:` from `TEMPLATE` to the client name (e.g., `jones-plumbing`)
- [ ] **`serverless.yml`** — change the prod domain from `TEMPLATE.stsites.dev` to the client's actual domain (e.g., `jonesplumbing.com`)
- [ ] **`package.json`** — change `"name"` from `"website-template"` to `"[client-name]"`
- [ ] **`README.md`** — replace all `[square bracket]` placeholders with client info
- [ ] **`MEMORY.md`** — fill in design decisions, color palette, sections, etc. as you build the site

---

## 3. GitHub Secrets

Secrets are NEVER stored in this repo. Create each one in the new repo on GitHub:

**Settings → Secrets and variables → Actions → New repository secret**

- [ ] **`AWS_ACCESS_KEY_ID`** — IAM user access key (needs S3, CloudFront, Route53 permissions)
- [ ] **`AWS_SECRET_ACCESS_KEY`** — Corresponding secret key for the IAM user above
- [ ] **`ACM_CERTIFICATE_ARN`** — ARN of the validated ACM certificate in `us-east-1` for the production domain (see step 4)
- [ ] **`HOSTED_ZONE_ID`** — Route53 hosted zone ID for the production domain (e.g., `ZXXXXXXXXXXXXX`)

---

## 4. Domain & Certificate

- [ ] Purchase or transfer the domain (Route53 recommended — creates hosted zone automatically)
- [ ] If domain is outside Route53, create a hosted zone manually and copy the ID
- [ ] Run `./scripts/create-acm-cert.sh [domain]` to create and validate the ACM certificate in `us-east-1`
- [ ] Copy the certificate ARN into the `ACM_CERTIFICATE_ARN` GitHub secret
- [ ] Copy the hosted zone ID into the `HOSTED_ZONE_ID` GitHub secret

---

## 5. Build the Site

- [ ] **`site/index.html`** — Build out from scratch (or copy structure from a vertical template)
- [ ] **`site/css/style.css`** — Add styles
- [ ] **`site/js/main.js`** — Add interactivity
- [ ] **`site/404.html`** and **`site/thanks.html`** — Branded error/form-success pages
- [ ] **`site/robots.txt`** — Point to sitemap
- [ ] **`site/sitemap.xml`** — List all pages
- [ ] **`site/assets/`** — Add images, icons, fonts, favicon
- [ ] Replace all `[square bracket]` placeholders throughout `site/` with client values

---

## 6. Deploy

- [ ] Push to `main` → GitHub Action auto-deploys to **staging** (CloudFront default URL)
- [ ] Verify staging: check the Actions tab for the staging URL, open it, test everything
- [ ] When ready, tag and push: `git tag v1.0.0 && git push --tags`
- [ ] GitHub Action deploys to **production** (custom domain + HTTPS via ACM)
- [ ] Verify production: visit the domain, test form, check mobile, run Lighthouse

---

## 7. Post-Launch

- [ ] Set up Stripe Billing subscription for the client
- [ ] Configure Stripe Tax for Texas sales tax (if client is in Texas)
- [ ] Add the client to `st-sites/knowledge/clients.md`
- [ ] Check off this item and archive this TODO.md — ongoing tasks go in the client repo's TODO.md
