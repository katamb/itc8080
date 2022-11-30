#!/bin/bash

source $(dirname "$0")/modprobe_audit_and_fixing.sh

echo "---"
echo "1.1.1.1 Ensure mounting of cramfs filesystems is disabled"
audit_and_fix "cramfs"
echo -e "---\n"

echo "---"
echo "1.1.1.2 Ensure mounting of squashfs filesystems is disabled"
audit_and_fix "squashfs"
echo -e "---\n"

echo "---"
echo "1.1.1.3 Ensure mounting of udf filesystems is disabled"
audit_and_fix "udf"
echo -e "---\n"
