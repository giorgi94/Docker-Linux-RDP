# Use Debian 13 as the base image
FROM debian:13.4

# ── Build arguments ───────────────────────────────────────────
ARG USERNAME=abc
ARG USER_PASSWORD=abc

# ── Environment ───────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TZ=UTC

# ── System update & package installation ─────────────────────
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        dbus-x11 x11-xserver-utils \
        xrdp tigervnc-standalone-server tigervnc-tools \
        xfce4 xfce4-goodies xfce4-whiskermenu-plugin \
        wget curl vim htop sudo ncdu \
        novnc websockify \
        locales \
        dos2unix && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ── XRDP setup ────────────────────────────────────────────────
RUN adduser xrdp ssl-cert && \
    echo "startxfce4" > /etc/skel/.xsession && \
    echo "startxfce4" > /root/.xsession && \
    echo "xfce4-session" > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh


# ── VNC password setup ────────────────────────────────────────
RUN mkdir -p /root/.config/tigervnc && \
    echo "password" | tigervncpasswd -f > /root/.config/tigervnc/passwd && \
    chmod 600 /root/.config/tigervnc/passwd

# ── SSH server setup ──────────────────────────────────────────
# RUN mkdir -p /var/run/sshd && \
#     sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
#     sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ── User setup ────────────────────────────────────────────────
RUN useradd -m -s /bin/bash ${USERNAME} && \
    echo "${USERNAME}:${USER_PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USERNAME}

# ── Entrypoint ────────────────────────────────────────────────
EXPOSE 3389 22 6080
COPY --chmod=755 init.sh /root/system_init.sh
RUN dos2unix /root/system_init.sh
ENTRYPOINT ["/root/system_init.sh"]