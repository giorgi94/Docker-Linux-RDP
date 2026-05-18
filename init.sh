#!/bin/bash
set -e

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Start XRDP session manager (background)
/usr/sbin/xrdp-sesman

# Start XRDP in foreground to keep the container alive
exec /usr/sbin/xrdp --nodaemon