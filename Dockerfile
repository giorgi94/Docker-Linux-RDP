FROM debian:13.4

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install all packages in a single layer so apt-get clean
# actually reduces image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xorg \
        dbus-x11 \
        x11-xserver-utils \
        xrdp \
        openssh-server \
        wget \
        curl \
        vim \
        htop \
        sudo \
        ncdu \
        # KDE Plasma desktop
        kde-plasma-desktop \
        plasma-workspace \
        kde-standard \
        sddm \
        # Useful KDE extras (trim as desired)
        konsole \
        dolphin \
        kate \
        ark \
        # Needed for clean KDE session under XRDP
        dbus \
        dbus-user-session \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# XRDP – configure to launch a KDE Plasma session
# ------------------------------------------------------------------
RUN adduser xrdp ssl-cert

# Write a proper startwm.sh with shebang so XRDP can execute it
RUN printf '#!/bin/sh\nexec startplasma-x11\n' > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Provide a fallback .xsession for non-XRDP X logins (root not used
# for login, but keeps the skeleton tidy for new users)
RUN echo "exec startplasma-x11" > /etc/skel/.xsession

# ------------------------------------------------------------------
# SSH server – harden defaults
# ------------------------------------------------------------------
RUN mkdir -p /run/sshd && \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ------------------------------------------------------------------
# Unprivileged user
# Pass USER_PASSWORD at build time: --build-arg USER_PASSWORD=secret
# Falls back to a placeholder that forces a password change on first login.
# ------------------------------------------------------------------
ARG USER_PASSWORD=abc
RUN useradd -m -s /bin/bash abc && \
    echo "abc:${USER_PASSWORD}" | chpasswd && \
    usermod -aG sudo abc && \
    # Give the user a KDE session file for XRDP
    echo "exec startplasma-x11" > /home/abc/.xsession && \
    chown abc:abc /home/abc/.xsession

# ------------------------------------------------------------------
# Ports
# ------------------------------------------------------------------
EXPOSE 3389 22

# ------------------------------------------------------------------
# Health check – verify XRDP is accepting connections
# ------------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD bash -c 'cat /dev/null > /dev/tcp/localhost/3389' || exit 1

# ------------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------------
COPY init.sh /root/system_init.sh
RUN chmod +x /root/system_init.sh

ENTRYPOINT ["/root/system_init.sh"]