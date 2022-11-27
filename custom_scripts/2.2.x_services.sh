#!/bin/bash

echo "2.2.1 Ensure X Window System is not installed"
if [ "$(dpkg-query -W -f='${binary:Package}\t${Status}\t${db:Status-Status}\n' xserver-xorg* 2>&1 | grep -Pi -c '\h+installed\b')" == 0 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nX Window System is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nX Window System is installed\n"

  echo "Remediating"
  apt purge xserver-xorg* -y
fi

echo "2.2.2 Ensure Avahi Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' avahi-daemon 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nAvahi Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nAvahi Server is installed\n"

  echo "Remediating"
  systemctl stop avahi-daemon.service
  systemctl stop avahi-daemon.socket
  apt purge avahi-daemon -y
fi

echo "2.2.3 Ensure CUPS is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' cups 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nCUPS is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nCUPS is installed\n"

  echo "Remediating"
  apt purge cups -y
fi

echo "2.2.4 Ensure DHCP Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' isc-dhcp-server 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nDHCP Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nDHCP Server is installed\n"

  echo "Remediating"
  apt purge isc-dhcp-server -y
fi

echo "2.2.5 Ensure LDAP server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' slapd 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nLDAP Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nLDAP Server is installed\n"

  echo "Remediating"
  apt purge slapd -y
fi

echo "2.2.6 Ensure NFS is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' nfs-kernel-server 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nNFS is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nNFS is installed\n"

  echo "Remediating"
  apt purge nfs-kernel-server -y
fi

echo "2.2.7 Ensure DNS Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' bind9 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nDNS Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nDNS Server is installed\n"

  echo "Remediating"
  apt purge bind9 -y
fi

echo "2.2.8 Ensure FTP Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' vsftpd 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nFTP Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nFTP Server is installed\n"

  echo "Remediating"
  apt purge vsftpd -y
fi

echo "2.2.9 Ensure HTTP server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' apache2 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nHTTP Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nHTTP Server is installed\n"

  echo "Remediating"
  apt purge apache2 -y
fi

echo "2.2.10 Ensure IMAP and POP3 server are not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' dovecot-imapd 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result for IMAP:\n ** PASS **\nIMAP Server is not installed\n"
else
  echo -e "\n- Audit Result for IMAP:\n ** FAIL **\n - Reason(s) for audit failure:\nIMAP Server is installed\n"

  echo "Remediating"
  apt purge dovecot-imapd -y
fi
if [ "$(dpkg-query -W -f='${db:Status-Status}' dovecot-pop3d 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result for POP3:\n ** PASS **\nPOP3 Server is not installed\n"
else
  echo -e "\n- Audit Result for POP3:\n ** FAIL **\n - Reason(s) for audit failure:\nPOP3 Server is installed\n"

  echo "Remediating"
  apt purge dovecot-pop3d -y
fi

echo "2.2.11 Ensure Samba is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' samba 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nSamba Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nSamba Server is installed\n"

  echo "Remediating"
  apt purge samba -y
fi

echo "2.2.12 Ensure HTTP Proxy Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' squid 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nHTTP Proxy Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nHTTP Proxy Server is installed\n"

  echo "Remediating"
  apt purge squid -y
fi

echo "2.2.13 Ensure SNMP Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' snmp 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nSNMP Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nSNMP Server is installed\n"

  echo "Remediating"
  apt purge snmp -y
fi

echo "2.2.14 Ensure NIS Server is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' nis 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nNIS Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nNIS Server is installed\n"

  echo "Remediating"
  apt purge nis -y
fi

echo "2.2.15 Ensure mail transfer agent is configured for local-only mode"
echo "NOT DISABLING - requires modifying conf file manually"

echo "2.2.16 Ensure rsync service is either not installed or masked"
if [ "$(dpkg-query -W -f='${db:Status-Status}' nis 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nrsync is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nrsync is installed\n"

  echo "Remediating"
  apt purge rsync -y
fi
