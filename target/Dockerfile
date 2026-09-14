FROM ubuntu:24.04

ARG WAZUH_MANAGER=wazuh.manager

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      openssh-server rsyslog curl gnupg lsb-release ca-certificates && \
    mkdir -p /var/run/sshd /var/log

# Deliberately weak login for the brute-force scenario.
RUN useradd -m -s /bin/bash labuser && \
    echo 'labuser:labpass123' | chpasswd

RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
      > /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && \
    WAZUH_MANAGER="${WAZUH_MANAGER}" DEBIAN_FRONTEND=noninteractive apt-get install -y wazuh-agent && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
