# Home SOC Lab

Status: in progress, not yet functional.

A small, self-contained lab for practicing blue-team / SOC-analyst work: generating attack traffic against a test target and detecting it with a real SIEM, instead of only completing guided platform exercises.

## Goal

- Run Wazuh (open-source SIEM) locally via Docker.
- Set up a deliberately vulnerable test target on an isolated local network.
- Generate known attack traffic against the target (e.g. Nmap scans, brute-force login attempts).
- Confirm Wazuh detects and alerts on it, and document what the alert looks like and why it fired.

## Planned stack

- Wazuh manager + indexer (Docker Compose)
- A vulnerable test VM/container as the target
- Attack tooling already practiced on TryHackMe (Nmap, Metasploit, Hydra)

## Why

Practical follow-up to completing TryHackMe's Pre Security path (53 rooms). Guided rooms teach the tools; this lab is about building something that detects misuse of them, not just using them.
