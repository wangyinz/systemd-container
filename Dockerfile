FROM quay.io/centos/centos:stream9

RUN dnf -y install \
        systemd \
        systemd-libs \
        systemd-udev \
        iproute \
        passwd \
    && dnf clean all \
    && rm -rf /var/cache/dnf

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
