#!/bin/bash for svc in bind9 nginx php8.4-fpm; do echo "=== $svc ===" systemctl is-active $svc || true done

