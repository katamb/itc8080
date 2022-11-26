#!/usr/bin/env bash

source ./modprobe_audit_and_fixing.sh

echo "3.1.2 Ensure wireless interfaces are disabled"
echo "NOT DISABLING"

echo "3.1.3 Ensure DCCP is disabled"
audit_and_fix "dccp"

echo "3.1.4 Ensure SCTP is disabled"
audit_and_fix "sctp"

echo "3.1.4 Ensure RDS is disabled"
audit_and_fix "rds"

echo "3.1.4 Ensure TIPC is disabled"
audit_and_fix "tipc"
