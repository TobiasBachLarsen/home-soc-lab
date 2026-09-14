# Home SOC Lab

Status: both detection scenarios below are working end to end. Demo
recording and write-up of *why* each alert fires are still to come.

A small, self-contained lab for practicing blue-team / SOC-analyst work: generating attack traffic against a test target and detecting it with a real SIEM, instead of only completing guided platform exercises.

## Stack

- **Wazuh** (manager + indexer + dashboard), official single-node Docker quickstart — [wazuh/](wazuh/)
- **Target container**: Ubuntu with OpenSSH (weak, deliberately breakable credentials) and a Wazuh agent — [target/](target/)
- **Suricata**, sharing the target's network namespace, feeding alerts to Wazuh through its built-in Suricata integration — [suricata/](suricata/)
- **Attacker tooling**: Hydra and Nmap, run against the target from outside its network namespace

Built and run on a throwaway cloud VM during development (snapshotted and
torn down between sessions), not a permanently hosted box — see the
project brief for why. Local-only would also work; this repo doesn't
assume either.

## Verified so far

1. **SSH brute-force**: repeated failed logins against the target trigger
   Wazuh's stock sshd/PAM rules (`sshd: authentication failed`, and
   `sshd: brute force trying to get access to the system` once several
   failures land in a short window).
2. **Nmap scan**: a SYN scan against the target is caught by Suricata
   (one local rule — see [suricata/README.md](suricata/README.md) for why)
   and surfaces in Wazuh via its built-in Suricata alert integration, no
   custom Wazuh-side rule needed.

## Why

Practical follow-up to completing TryHackMe's Pre Security path (53 rooms). Guided rooms teach the tools; this lab is about building something that detects misuse of them, not just using them.
