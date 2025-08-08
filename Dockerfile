FROM quay.io/centos/centos:stream9
ENV container=docker

RUN dnf -y install \
        systemd \
        systemd-libs \
        systemd-udev \
        systemd-container \
        iproute \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN cat >/usr/local/bin/entrypoint.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -eq 0 ]; then            # no args → become systemd
    exec /usr/sbin/init
else                               # args supplied → run them instead
    exec "$@"
fi
EOF
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
