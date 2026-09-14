# Triage: enriching the SSH brute-force alert

Detecting an alert is only half the job. This is the step that comes after
rule 5763 fires: pull the source IP out of the alert and find out what it
actually is before deciding what to do about it.

## Getting a real public source IP

By default, the attacker traffic in this lab runs from the same Docker host
as the target, so the alert's `srcip` is the internal docker network address
(`172.18.0.1`), not useful to look up. To get a real, externally-routable
source IP, `target`'s SSH port was briefly published on the host and allowed
through the Hetzner firewall for one IP only (the operator's own), then
closed again right after:

```
docker compose -f docker-compose.yml -f triage/docker-compose.override.yml up -d target
hcloud firewall add-rule home-soc-lab-fw --direction in --protocol tcp --port 2222 --source-ips <your-ip>/32
# run the brute-force attempt from outside the server, against <server-ip>:2222
hcloud firewall delete-rule home-soc-lab-fw --direction in --protocol tcp --port 2222 --source-ips <your-ip>/32
docker compose up -d target   # drops back to the default, unpublished config
```

That produced a real alert with `srcip: 80.199.8.220`, the operator's own
home connection. Rule 5763 fired the same way it did for the internal-IP
version: `sshd: brute force trying to get access to the system. Authentication
failed.`, level 10.

## Enriching the IP

[`osint-lookup.sh`](osint-lookup.sh) queries ip-api.com's free tier (no API
key, 45 requests/min) for geolocation, ISP/org, ASN, and whether the IP is a
known proxy or hosting/datacenter range:

```
./triage/osint-lookup.sh 80.199.8.220
```

```json
{
  "status": "success",
  "country": "Denmark",
  "regionName": "Central Jutland",
  "city": "Ikast",
  "isp": "TDC Tele Danmark",
  "org": "TDC A/S",
  "as": "AS3292 TDC Holding A/S",
  "reverse": "80-199-8-220-cable.dk.customer.tdc.net",
  "proxy": false,
  "hosting": false,
  "query": "80.199.8.220"
}
```

## Reading it

This one resolves to a residential ISP connection in Denmark, not a
hosting/datacenter range and not a known proxy, because it's the lab
operator's own IP, not a real attacker. That's the actual point of this
step: the `hosting`/`proxy` flags and the ASN are what separate "automated
scanning from cloud/hosting infrastructure" (the overwhelmingly common
pattern for real internet-facing SSH brute-force) from "a real person's own
connection", which matters for how an analyst would triage it. An IP
resolving to a known hosting provider or flagged as a proxy on an
unrecognized SSH login raises the priority; one resolving to a normal
residential ISP with no other red flags might just be a mistyped password
from a legitimate user, worth a quick check rather than an incident.

In a real SOC this is the point where you'd cross-reference the IP against
threat-intel feeds (AbuseIPDB, VirusTotal, Shodan) for prior-reported
abuse, and decide whether to block it via the firewall or Wazuh's
active-response. That's a manual decision, not something this script
makes for you.
