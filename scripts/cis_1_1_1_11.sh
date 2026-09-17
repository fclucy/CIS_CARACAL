#!/bin/bash

#
# CIS_CARACAL
# CIS Debian 13 Benchmark 1.1.1.11
#
# Ensure unused filesystems kernel modules are not available
#

set -u

PASS=0
FAIL=0
WARNING=0

echo "========================================"
echo " CIS_CARACAL"
echo " CIS 1.1.1.11 Audit"
echo "========================================"
echo

echo "[+] System Information"
echo "Kernel: $(uname -r)"
echo

#
# ---------------------------------------------------------
# Step 1: Determine mounted filesystem types
# ---------------------------------------------------------
#

echo "[+] Discovering mounted filesystem types..."

MOUNTED_FILESYSTEMS=$(
    findmnt -Dkerno fstype 2>/dev/null |
    sort -u
)

if [ -z "$MOUNTED_FILESYSTEMS" ]; then
    echo "WARNING: Unable to determine mounted filesystems."
    WARNING=$((WARNING + 1))
else
    echo "$MOUNTED_FILESYSTEMS"
fi

echo

#
# ---------------------------------------------------------
# Step 2: Locate filesystem kernel modules
# ---------------------------------------------------------
#

KERNEL_VERSION="$(uname -r)"

if [ -d "/usr/lib/modules/${KERNEL_VERSION}/kernel/fs" ]; then
    MODULE_PATH="/usr/lib/modules/${KERNEL_VERSION}/kernel/fs"
elif [ -d "/lib/modules/${KERNEL_VERSION}/kernel/fs" ]; then
    MODULE_PATH="/lib/modules/${KERNEL_VERSION}/kernel/fs"
else
    echo "FAIL: Filesystem kernel module directory not found."
    exit 1
fi

echo "[+] Filesystem kernel module directory:"
echo "$MODULE_PATH"
echo

echo "[+] Discovering filesystem kernel modules..."

AVAILABLE_MODULES=$(
    find "$MODULE_PATH" \
        -type f \
        \( -name "*.ko" -o -name "*.ko.xz" -o -name "*.ko.zst" -o -name "*.ko.gz" \) \
        ! -path "*/nls/*" \
        -print |
    sed -E 's#.*/##' |
    sed -E 's#\.ko(\..*)?$##' |
    sort -u
)

if [ -z "$AVAILABLE_MODULES" ]; then
    echo "FAIL: No filesystem kernel modules discovered."
    exit 1
fi

echo "$AVAILABLE_MODULES"
echo

#
# ---------------------------------------------------------
# Step 3: Determine currently loaded modules
# ---------------------------------------------------------
#

echo "[+] Discovering loaded modules..."

LOADED_MODULES=$(
    lsmod |
    awk 'NR > 1 {print $1}'
)

echo "$LOADED_MODULES"
echo

#
# ---------------------------------------------------------
# Step 4: Determine modprobe configuration
# ---------------------------------------------------------
#

echo "[+] Reading modprobe configuration..."

MODPROBE_CONFIG=$(
    modprobe --showconfig 2>/dev/null |
    grep -E '^[[:space:]]*(blacklist|install)[[:space:]]+' ||
    true
)

if [ -n "$MODPROBE_CONFIG" ]; then
    echo "$MODPROBE_CONFIG"
else
    echo "No blacklist/install entries found."
fi

echo

#
# ---------------------------------------------------------
# Step 5: Check loaded filesystem modules
# ---------------------------------------------------------
#

echo "========================================"
echo " Loaded Filesystem Modules"
echo "========================================"

LOADED_FILESYSTEM_MODULES=""

while read -r module; do

    if echo "$AVAILABLE_MODULES" | grep -Fxq "$module"; then

        LOADED_FILESYSTEM_MODULES="$LOADED_FILESYSTEM_MODULES
$module"

        echo "[WARNING] Filesystem module loaded: $module"
        WARNING=$((WARNING + 1))

    fi

done <<< "$LOADED_MODULES"

if [ -z "$LOADED_FILESYSTEM_MODULES" ]; then
    echo "No filesystem modules from the discovered list are loaded."
fi

echo

#
# ---------------------------------------------------------
# Step 6: Check whether unused modules are restricted
# ---------------------------------------------------------
#

echo "========================================"
echo " Unused Filesystem Module Assessment"
echo "========================================"

for module in $AVAILABLE_MODULES; do

    #
    # Check whether the module corresponds to a mounted
    # filesystem.
    #

    if echo "$MOUNTED_FILESYSTEMS" | grep -Fxq "$module"; then
        continue
    fi

    #
    # Some filesystem modules have names that differ from
    # their filesystem type. For now, report them as
    # candidates requiring administrator review.
    #

    BLACKLISTED=false
    INSTALL_DISABLED=false

    if echo "$MODPROBE_CONFIG" |
        grep -Eq "^[[:space:]]*blacklist[[:space:]]+${module}([[:space:]]|$)"
    then
        BLACKLISTED=true
    fi

    if echo "$MODPROBE_CONFIG" |
        grep -Eq "^[[:space:]]*install[[:space:]]+${module}[[:space:]]+/bin/(false|true)([[:space:]]|$)"
    then
        INSTALL_DISABLED=true
    fi

    if [ "$BLACKLISTED" = true ] && [ "$INSTALL_DISABLED" = true ]; then

        echo "[PASS] $module is restricted."

        PASS=$((PASS + 1))

    else

        echo "[FAIL] $module is not fully restricted."

        if [ "$BLACKLISTED" = false ]; then
            echo "       Missing blacklist directive."
        fi

        if [ "$INSTALL_DISABLED" = false ]; then
            echo "       Missing install restriction."
        fi

        FAIL=$((FAIL + 1))

    fi

done

echo

#
# ---------------------------------------------------------
# Step 7: Final report
# ---------------------------------------------------------
#

echo "========================================"
echo " Audit Summary"
echo "========================================"

echo "PASS:     $PASS"
echo "FAIL:     $FAIL"
echo "WARNING:  $WARNING"

echo

if [ "$FAIL" -gt 0 ]; then

    echo "RESULT: FAIL"
    exit 2

elif [ "$WARNING" -gt 0 ]; then

    echo "RESULT: WARNING"
    exit 3

else

    echo "RESULT: PASS"
    exit 0

fi

