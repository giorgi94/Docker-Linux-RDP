#!/bin/bash

/usr/sbin/sshd
/bin/bash -c /usr/sbin/xrdp-sesman && /usr/sbin/xrdp --nodaemon

