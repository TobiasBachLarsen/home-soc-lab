# Triage: enriching the SSH brute-force alert

Detecting an alert is only half the job. This is the step that comes after
rule 5763 fires: pull the source IP out of the alert and find out what it
actually is before deciding what to do about it.

## Getting a real public source IP

By default, the attacker traffic in this lab runs from the same Docker host
as the target, so the alert's `srcip` is the internal docker network address
(`172.18.0.1`), not useful to look up. To get a real, externally-routable
source IP, `target`'s SSH port was briefly published on the host, **always
paired with a firewall rule scoping it to one IP**, then closed again right
after. Never run the override file without that firewall rule; without it,
`target`'s weak-credential SSH would be open to the whole internet:

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

[`osint-lookup.sh`](osint-lookup.sh) queries ipinfo.io's free tier (no API
key, HTTPS, generous rate limit) for geolocation, ISP/org, ASN, and reverse
DNS:

```
./triage/osint-lookup.sh 80.199.8.220
```

```json
{
  "ip": "80.199.8.220",
  "hostname": "80-199-8-220-cable.dk.customer.tdc.net",
  "city": "Silkeborg",
  "region": "Central Jutland",
  "country": "DK",
  "org": "AS3292 TDC Holding A/S",
  "timezone": "Europe/Copenhagen"
}
```

(An earlier version of this script used ip-api.com over plain HTTP with
explicit `proxy`/`hosting` flags. It got switched to ipinfo.io over HTTPS
after a review flagged the unencrypted lookup as MITM-tamperable, someone
on the network path could otherwise alter the response and make a
malicious IP look clean. ipinfo.io's free tier doesn't return those
boolean flags, so the org/ASN string is what you read manually instead.)

## Reading it

`AS3292 TDC Holding A/S` is a residential Danish ISP, not a cloud or
hosting provider, because this is the lab operator's own IP, not a real
attacker. That's the actual point of this step: recognizing whether an
ASN belongs to a known hosting/cloud provider (the overwhelmingly common
pattern for real internet-facing SSH brute-force, since that traffic is
almost always automated from rented infrastructure) versus a residential
ISP is what separates "likely automated scanning" from "a real person's
own connection", and that distinction drives the triage priority. An
unrecognized login from a known hosting/VPN provider's ASN raises the
priority; one from an ordinary residential ISP with no other red flags
might just be a mistyped password from a legitimate user, worth a quick
check rather than an incident.

In a real SOC this is the point where you'd cross-reference the IP against
threat-intel feeds (AbuseIPDB, VirusTotal, Shodan) for prior-reported
abuse, and decide whether to block it via the firewall or Wazuh's
active-response. That's a manual decision, not something this script
makes for you.
