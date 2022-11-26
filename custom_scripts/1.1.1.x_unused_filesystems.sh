#!/bin/bash

source $(dirname "$0")/modprobe_audit_and_fixing.sh

audit_and_fix "cramfs"
audit_and_fix "squashfs"
audit_and_fix "udf"
