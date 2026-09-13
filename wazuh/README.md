# Wazuh stack

Single-node Wazuh (manager + indexer + dashboard), based on the official
wazuh-docker quickstart, with default demo credentials replaced.

## First-time setup

1. Generate the indexer TLS certs (writes to `config/wazuh_indexer_ssl_certs/`, gitignored):
   ```
   docker compose -f generate-indexer-certs.yml run --rm generator
   ```

2. Copy `.env.example` to `.env` and set real passwords:
   ```
   cp .env.example .env
   ```

3. The indexer checks passwords against bcrypt hashes in
   `config/wazuh_indexer/internal_users.yml`, not against `.env` directly.
   After changing `INDEXER_PASSWORD` or `DASHBOARD_PASSWORD` in `.env`,
   regenerate the matching hash and paste it into that file:
   ```
   docker run --rm -e JAVA_HOME=/usr/share/wazuh-indexer/jdk \
     --entrypoint /usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh \
     wazuh/wazuh-indexer:4.14.7 -p 'your-new-password'
   ```
   Put the `admin` hash under `admin:` and the `kibanaserver` hash under
   `kibanaserver:`.

4. `config/wazuh_dashboard/wazuh.yml` also holds the API password (the
   dashboard's Wazuh plugin reads it directly, not through `.env`), so it's
   gitignored. Build it from the example before first start:
   ```
   sed "s/\${API_PASSWORD}/your-api-password/" \
     config/wazuh_dashboard/wazuh.yml.example > config/wazuh_dashboard/wazuh.yml
   ```

5. Start the stack:
   ```
   sysctl -w vm.max_map_count=262144
   docker compose up -d
   ```

Dashboard is on port 443 (not exposed publicly here, reached over an SSH
tunnel). Manager API is on 55000.

## Known limitations

- The unused demo accounts (`kibanaro`, `logstash`, `readall`,
  `snapshotrestore`) are removed from `internal_users.yml` rather than just
  password-rotated, since nothing in this stack uses them.
- `wazuh.indexer.yml` disables transport-layer hostname verification
  (`enforce_hostname_verification: false`). That's inherited unchanged from
  Wazuh's own single-node quickstart: with one node there's nothing else to
  verify a hostname against. It would need revisiting for a multi-node
  cluster.
