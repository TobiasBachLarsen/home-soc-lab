#!/bin/bash
# Quick OSINT enrichment for an IP seen in a Wazuh alert: geolocation, ISP/org,
# ASN, and whether it's flagged as a known proxy or hosting/datacenter range.
# Free, no API key: ip-api.com's free tier (45 req/min, non-commercial use).
set -e

IP="$1"
if [ -z "$IP" ]; then
  echo "Usage: $0 <ip>"
  exit 1
fi

curl -s "http://ip-api.com/json/${IP}?fields=status,message,query,country,regionName,city,isp,org,as,proxy,hosting,reverse" | jq .
