#!/bin/bash

#
# CIS_CARACAL
# CIS Debian 13 Benchmark 1.1.1.11
#
# Ensure unused filesystems kernel modules are not available
#

set -u

echo "========================================"
echo " CIS_CARACAL - CIS 1.1.1.11 Audit"
echo "========================================"
echo

echo "[+] System Information"
echo "Kernel: $(uname -r)"
echo

echo "[+] Mounted Filesystem Types"
findmnt -Dkerno fstype | sort -u
echo

echo "[+] Filesystem Kernel Modules"

KERNEL_VERSION="$(uname -r)"

if [ -d "/usr/lib/modules/${KERNEL_VERSION}/kernel/fs" ]; then
    MODULE_PATH="/usr/lib/modules/${KERNEL_VERSION}/kernel/fs"
elif [ -d "/lib/modules/${KERNEL_VERSION}/kernel/fs" ]; then
    MODULE_PATH="/lib/modules/${KERNEL_VERSION}/kernel/fs"
else
    echo "ERROR: Filesystem kernel module directory not found."
    exit 1
fi

echo "Module path: ${MODULE_PATH}"
echo

find "${MODULE_PATH}" \
    -type f \
    \( -name "*.ko" -o -name "*.ko.xz" -o -name "*.ko.zst" -o -name "*.ko.gz" \) \
    ! -path "*/nls/*" \
    -print |
    sed -E 's#.*/##' |
    sed -E 's#\.ko(\..*)?$##' |
    sort -u

echo

echo "[+] Currently Loaded Kernel Modules"
lsmod
echo

echo "[+] Modprobe Blacklist / Install Configuration"
sudo modprobe --showconfig |
    grep -E '^[[:space:]]*(blacklist|install)[[:space:]]+' ||
    echo "No matching blacklist/install entries found."

echo
echo "========================================"
echo " Audit complete"
echo "========================================"
