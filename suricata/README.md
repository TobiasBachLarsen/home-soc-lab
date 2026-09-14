# Suricata

Runs in the target container's network namespace (`network_mode:
"service:target"`) so it can sniff traffic on `eth0` without extra network
plumbing. Alerts go to `eve.json` on a volume shared with the target, where
the target's Wazuh agent picks them up and forwards them to the manager,
which decodes them with its built-in Suricata integration (rule group
`suricata`, ids 86601+). No custom Wazuh-side rule needed.

## First-time setup

Rules aren't baked into the image; pull them once before starting:
```
docker compose run --rm suricata suricata-update --local /etc/suricata/local.rules
docker compose up -d suricata
```

`--local` merges `local.rules` into the compiled ruleset. Re-run the same
command to pick up rule updates later.

## Why there's a local rule

Emerging Threats Open (the ruleset `suricata-update` pulls by default) is
built around known tool/traffic fingerprints, not a generic port-scan
detector — a plain Nmap SYN scan against a host with only one open port
didn't match anything in it during testing. `local.rules` adds one rule
using Suricata's own `threshold` keyword (a built-in feature, not a custom
detection engine) to flag many SYNs from one source in a short window.
