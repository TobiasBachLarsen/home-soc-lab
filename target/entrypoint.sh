#!/bin/bash
set -e

touch /var/log/auth.log
/var/ossec/bin/wazuh-control start

exec /usr/sbin/sshd -D -E /var/log/auth.log
