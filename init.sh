#!/bin/bash
set -e

# Start SSH daemon
/usr/sbin/sshd

# Start XRDP session manager in the background
/usr/sbin/xrdp-sesman &

# Start XRDP in the foreground (keeps container alive, catches crashes)
exec /usr/sbin/xrdp --nodaemon