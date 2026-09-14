#!/bin/bash
set -e

# Pre-create log files so the Wazuh agent's logcollector doesn't start
# before they exist and give up watching them.
install -o syslog -g adm -m 640 /dev/null /var/log/auth.log
mkdir -p /var/log/suricata
touch /var/log/suricata/eve.json
chmod 666 /var/log/suricata/eve.json

rm -f /run/rsyslogd.pid
rsyslogd

grep -q '/var/log/auth.log' /var/ossec/etc/ossec.conf || cat >> /var/ossec/etc/ossec.conf << 'EOF'

<ossec_config>
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>

  <localfile>
    <log_format>json</log_format>
    <location>/var/log/suricata/eve.json</location>
  </localfile>
</ossec_config>
EOF

/var/ossec/bin/wazuh-control start

exec /usr/sbin/sshd -D
