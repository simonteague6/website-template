#!/bin/bash
# create-acm-cert.sh — Request + validate an ACM certificate via Route53 DNS
# Usage: ./scripts/create-acm-cert.sh <domain>
# Example: ./scripts/create-acm-cert.sh plumber.demo.stsites.dev
#
# Requirements:
#   - AWS CLI configured with the stsites profile
#   - A Route53 hosted zone that matches the domain
#   - Cert is created in us-east-1 (required for CloudFront)

set -euo pipefail

# --- Cleanup trap: always delete the validation CNAME record on exit ---
RECORD_CREATED=false
cleanup() {
  if [ "$RECORD_CREATED" = "true" ]; then
    echo ""
    echo "--- Cleaning up DNS validation record ---"
    aws route53 change-resource-record-sets \
      --profile "$AWS_PROFILE" \
      --hosted-zone-id "$ZONE_ID" \
      --change-batch "{
        \"Changes\": [{
          \"Action\": \"DELETE\",
          \"ResourceRecordSet\": {
            \"Name\": \"$RECORD_NAME\",
            \"Type\": \"$RECORD_TYPE\",
            \"TTL\": 300,
            \"ResourceRecords\": [{\"Value\": \"$RECORD_VALUE\"}]
          }
        }]
      }" \
      --query 'ChangeInfo.Id' \
      --output text 2>/dev/null || true
    echo "✓ Validation record cleaned up"
  fi
}
trap cleanup EXIT

DOMAIN="${1:?Usage: $0 <domain>}"
AWS_PROFILE="${AWS_PROFILE:-stsites}"
REGION="us-east-1"

echo "=== ACM Certificate Creation ==="
echo "Domain:   $DOMAIN"
echo "Profile:  $AWS_PROFILE"
echo "Region:   $REGION (required for CloudFront)"
echo ""

# 1. Find the matching Route53 hosted zone
echo "--- Finding hosted zone ---"
ZONE_ID=$(aws route53 list-hosted-zones --profile "$AWS_PROFILE" \
  --query "HostedZones[?ends_with('$DOMAIN.', Name)]|[0].Id" \
  --output text 2>/dev/null | sed 's|/hostedzone/||')

if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" = "None" ]; then
  echo "ERROR: No hosted zone found matching domain '$DOMAIN'"
  echo "Available zones:"
  aws route53 list-hosted-zones --profile "$AWS_PROFILE" \
    --query "HostedZones[*].Name" --output text 2>/dev/null
  exit 1
fi

ZONE_NAME=$(aws route53 get-hosted-zone --profile "$AWS_PROFILE" --id "$ZONE_ID" \
  --query "HostedZone.Name" --output text)
echo "Found zone: $ZONE_NAME ($ZONE_ID)"

# 2. Request the certificate
echo ""
echo "--- Requesting certificate ---"
CERT_ARN=$(aws acm request-certificate \
  --profile "$AWS_PROFILE" \
  --region "$REGION" \
  --domain-name "$DOMAIN" \
  --validation-method DNS \
  --query 'CertificateArn' \
  --output text)

echo "Cert ARN:  $CERT_ARN"

# 3. Get the DNS validation record (may take a moment to appear)
echo ""
echo "--- Retrieving validation record ---"
sleep 3

for i in $(seq 1 10); do
  VALIDATION=$(aws acm describe-certificate \
    --profile "$AWS_PROFILE" \
    --region "$REGION" \
    --certificate-arn "$CERT_ARN" \
    --query 'Certificate.DomainValidationOptions[0].ResourceRecord' \
    --output json 2>/dev/null)

  RECORD_NAME=$(echo "$VALIDATION" | jq -r '.Name // empty')
  if [ -n "$RECORD_NAME" ]; then
    break
  fi
  echo "  Waiting for validation record... attempt $i"
  sleep 3
done

if [ -z "$RECORD_NAME" ]; then
  echo "ERROR: Could not retrieve validation record"
  exit 1
fi

RECORD_TYPE=$(echo "$VALIDATION" | jq -r '.Type')
RECORD_VALUE=$(echo "$VALIDATION" | jq -r '.Value')

echo "  Name:  $RECORD_NAME"
echo "  Type:  $RECORD_TYPE"
echo "  Value: $RECORD_VALUE"

# 4. Create the DNS validation record in Route53
echo ""
echo "--- Creating DNS validation record ---"
CHANGE_ID=$(aws route53 change-resource-record-sets \
  --profile "$AWS_PROFILE" \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch "{
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$RECORD_NAME\",
        \"Type\": \"$RECORD_TYPE\",
        \"TTL\": 300,
        \"ResourceRecords\": [{\"Value\": \"$RECORD_VALUE\"}]
      }
    }]
  }" \
  --query 'ChangeInfo.Id' \
  --output text)

echo "DNS change submitted: $CHANGE_ID"
RECORD_CREATED=true

# 5. Wait for validation
echo ""
echo "--- Waiting for certificate validation ---"
for i in $(seq 1 60); do
  STATUS=$(aws acm describe-certificate \
    --profile "$AWS_PROFILE" \
    --region "$REGION" \
    --certificate-arn "$CERT_ARN" \
    --query 'Certificate.Status' \
    --output text)

  if [ "$STATUS" = "ISSUED" ]; then
    echo "✓ Certificate issued!"
    break
  fi
  echo "  [$i] $STATUS..."
  sleep 10
done

if [ "$STATUS" != "ISSUED" ]; then
  echo "ERROR: Certificate did not issue within 10 minutes. Status: $STATUS"
  exit 1
fi

# 6. Output summary
echo ""
echo "============================================"
echo "  Domain:     $DOMAIN"
echo "  Cert ARN:   $CERT_ARN"
echo "  Status:     $STATUS"
echo "  Zone:       $ZONE_NAME"
echo ""
echo "  GitHub secret command:"
echo "  gh secret set ACM_CERTIFICATE_ARN --body \"$CERT_ARN\""
echo ""
echo "  Deploy production:"
echo "  ACM_CERTIFICATE_ARN='$CERT_ARN' PROD_DOMAIN='$DOMAIN' npx serverless deploy --stage prod"
echo "============================================"
