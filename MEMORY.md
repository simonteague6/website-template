# MEMORY — [CLIENT_NAME]

AI assistant context for resuming work on this site.

## File Structure

```
.
├── site/
│   ├── index.html
│   ├── 404.html
│   ├── thanks.html
│   ├── robots.txt
│   ├── sitemap.xml
│   ├── css/style.css
│   ├── js/main.js
│   └── assets/
├── serverless.yml
├── package.json
├── .github/workflows/
│   ├── deploy-staging.yml
│   └── deploy-prod.yml
└── scripts/
```

## Client Info

- **Business name:** [CLIENT_NAME]
- **Domain:** [DOMAIN]
- **Industry/Vertical:** [VERTICAL]
- **Service area:** [SERVICE_AREA]
- **Phone:** [PHONE]
- **Email:** [EMAIL]

## Design Decisions

> Fill this in as design choices are made. Delete sections that don't apply.

### Layout

- **Type:** [Single-page / Multi-page]
- **Sections:** [List sections in page order]

### Color Palette

```
[color-name]   #[HEX]  — [usage description]
```

### Typography

- **Headings:** [Font name] (source: [Google Fonts / self-hosted / system])
- **Body:** [Font name]

### Key Patterns

- [Pattern 1 — e.g., "CSS custom properties in :root for all colors/spacing"]
- [Pattern 2 — e.g., ".reveal class for scroll-triggered animations"]

## Deployment

- **Staging:** Push to `main` → CloudFront default URL
- **Production:** Git tag `v*` → custom domain with ACM
- **AWS profile:** stsites

## Placeholders

All `[square bracket]` values in `site/` must be replaced before production deploy. Search `site/` for `[` to find them all.
