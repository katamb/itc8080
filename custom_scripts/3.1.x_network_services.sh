#!/bin/bash

source $(dirname "$0")/modprobe_audit_and_fixing.sh

echo "3.1.1 Ensure wireless interfaces are disabled"
echo "NOT DISABLING - may cause networking issues, especially in the future"

echo "3.1.2 Ensure wireless interfaces are disabled"
echo "NOT DISABLING - wireless is needed for most workstations"

echo "3.1.3 Ensure DCCP is disabled"
audit_and_fix "dccp"

echo "3.1.4 Ensure SCTP is disabled"
audit_and_fix "sctp"

echo "3.1.5 Ensure RDS is disabled"
audit_and_fix "rds"

echo "3.1.6 Ensure TIPC is disabled"
audit_and_fix "tipc"
