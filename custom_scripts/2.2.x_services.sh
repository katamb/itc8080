#!/bin/bash

echo "2.2.1 Ensure X Window System is not installed"
if [ "$(dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' xserver-xorg* | grep -Pi -c '\h+installed\b')" == 0 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nX Window System is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nX Window System is installed\n"

  echo "Remediating"
  apt purge xserver-xorg*
fi

echo "2.2.2 Ensure Avahi Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' avahi-daemon | grep -c 'not-installed')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nAvahi Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nAvahi Server is installed\n"

  echo "Remediating"
  systemctl stop avahi-daaemon.service
  systemctl stop avahi-daemon.socket
  apt purge avahi-daemon
fi

echo "2.2.3 Ensure CUPS is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' cups | grep -c 'not-installed')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nCUPS is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nCUPS is installed\n"

  echo "Remediating"
  apt purge cups
fi

echo "2.2.4 Ensure DHCP Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' isc-dhcp-server | grep -c 'not-installed')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nDHCP Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nDHCP Server is installed\n"

  echo "Remediating"
  apt purge isc-dhcp-server
fi

echo "2.2.5 Ensure LDAP server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' slapd | grep -c 'not-installed')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nLDAP Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nLDAP Server is installed\n"

  echo "Remediating"
  apt purge slapd
fi

echo "2.2.6 Ensure NFS is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' nfs-kernel-server | grep -c 'not-installed')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nNFS is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nNFS is installed\n"

  echo "Remediating"
  apt purge nfs-kernel-server
fi
