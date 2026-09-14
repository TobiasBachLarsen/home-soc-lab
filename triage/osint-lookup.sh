#!/bin/bash
# Quick OSINT enrichment for an IP seen in a Wazuh alert: geolocation,
# ISP/ASN, and reverse DNS. Free, no API key: ipinfo.io's free tier
# (~50k requests/month without a token), over HTTPS so the lookup itself
# can't be tampered with in transit.
set -e

IP="$1"
if [ -z "$IP" ]; then
  echo "Usage: $0 <ip>"
  exit 1
fi

curl -s "https://ipinfo.io/${IP}/json" | jq .
