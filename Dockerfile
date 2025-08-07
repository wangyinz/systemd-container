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

# --- entrypoint ---
RUN cat >/usr/local/bin/entrypoint.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# 1. Spawn systemd (PID 1) in the *background*
/usr/sbin/init &

# Optional: wait until systemd finishes its early boot
until systemctl --quiet is-system-running; do sleep 0.5; done

# 2. If the user supplied args, run them as a transient unit
if [ "$#" -gt 0 ]; then
    # --wait makes systemd-run attach and relay exit status
    systemd-run --wait --unit=container_cmd --pty "$@"
fi

# 3. Forward signals & wait on PID 1
pid=$!
trap "kill -SIGRTMIN+3 \$pid" SIGTERM
wait \$pid
EOF
RUN chmod +x /usr/local/bin/entrypoint.sh
VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
