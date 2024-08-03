# Use Debian 12 as the base image
FROM debian:12

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y xorg dbus-x11 x11-xserver-utils xrdp openssh-server
RUN apt-get install -y wget curl vim htop sudo ncdu
RUN apt-get install -y xfce4 xfce4-goodies xfce4-whiskermenu-plugin

# Clean Up cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up XRDP
RUN adduser xrdp ssl-cert && \
    echo "startxfce4" > /etc/skel/.xsession && \
    echo "startxfce4" > /root/.xsession && \
    sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini && \
    echo "xfce4-session" > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

# Set up SSH server
RUN mkdir /var/run/sshd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Open port for XRDP and SSH server
EXPOSE 3389 22

COPY init.sh /root/system_init.sh

# Create user
RUN useradd -m -s /bin/bash abc && echo "abc:abc" | chpasswd

RUN usermod -aG sudo abc

# Start XRDP and the XFCE desktop
CMD ["/bin/bash", "/root/system_init.sh"]

