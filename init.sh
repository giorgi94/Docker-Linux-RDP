#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8


# Start a dedicated Xvnc session for noVNC on display :1 (port 5901)
tigervncserver :1 -geometry 1920x1080 -depth 24 -localhost yes -rfbauth /root/.config/tigervnc/passwd

# Start XFCE4 in that display
DISPLAY=:1 startxfce4 &

# Start XRDP session manager (background)
/usr/sbin/xrdp-sesman

# Start noVNC websocket proxy on port 6080 → VNC port 5901
websockify --web /usr/share/novnc 6080 localhost:5901 &

# Start XRDP in foreground to keep the container alive
exec /usr/sbin/xrdp --nodaemon