#!/bin/bash

source $(dirname "$0")/modprobe_audit_and_fixing.sh

echo "---"
echo "1.1.10 Disable usb storage"
audit_and_fix "usb-storage"
echo -e "---\n"
