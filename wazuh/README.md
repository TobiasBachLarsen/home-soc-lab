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

4. Start the stack:
   ```
   sysctl -w vm.max_map_count=262144
   docker compose up -d
   ```

Dashboard is on port 443 (not exposed publicly here, reached over an SSH
tunnel). Manager API is on 55000.
