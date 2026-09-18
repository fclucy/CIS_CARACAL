#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AUDIT_SCRIPT="$SCRIPT_DIR/scripts/cis_1_1_1_11.sh"

if [ ! -f "$AUDIT_SCRIPT" ]; then
    zenity \
        --error \
        --title="CIS_CARACAL Error" \
        --text="Audit script not found:

$AUDIT_SCRIPT"

    exit 1
fi

CHOICE=$(zenity \
    --list \
    --title="CIS_CARACAL" \
    --text="Select a CIS audit to run:" \
    --column="CIS Control" \
    --column="Description" \
    "1.1.1.11" \
    "Unused filesystem kernel modules" \
    --width=700 \
    --height=300)

if [ $? -ne 0 ]; then
    exit 0
fi

if [ "$CHOICE" = "1.1.1.11" ]; then

    REPORT_FILE="$(mktemp)"

    trap 'rm -f "$REPORT_FILE"' EXIT

    bash "$AUDIT_SCRIPT" >"$REPORT_FILE" 2>&1
    RESULT=$?

    zenity \
        --text-info \
        --title="CIS 1.1.1.11 Audit Report" \
        --filename="$REPORT_FILE" \
        --width=900 \
        --height=700

    exit "$RESULT"
fi