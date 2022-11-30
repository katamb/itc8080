#!/bin/bash

echo "---"
echo "2.3.1 Ensure NIS Client is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' nis 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nNIS Server is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nNIS Server is installed\n"

  echo "Remediating"
  apt purge nis -y
fi
echo -e "---\n"

echo "---"
echo "2.3.2 Ensure rsh client is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' rsh-client 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nRSH client is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nRSH client is installed\n"

  echo "Remediating"
  apt purge rsh-client -y
fi
echo -e "---\n"

echo "---"
echo "2.3.3 Ensure talk client is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' talk 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\ntalk client is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\ntalk client is installed\n"

  echo "Remediating"
  apt purge talk -y
fi
echo -e "---\n"

echo "---"
echo "2.3.4 Ensure telnet client is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' telnet 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\ntelnet client is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\ntelnet client is installed\n"

  echo "Remediating"
  apt purge telnet -y
fi
echo -e "---\n"

echo "---"
echo "2.3.5 Ensure LDAP client is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' ldap-utils 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nLDAP client is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nLDAP client is installed\n"

  echo "Remediating"
  apt purge ldap-utils -y
fi
echo -e "---\n"

echo "---"
echo "2.3.6 Ensure RPC is not installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' rpcbind 2>&1 | grep -c 'not-installed\|no packages found')" == 1 ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nRPC is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nRPC is installed\n"

  echo "Remediating"
  apt purge rpcbind -y
fi
echo -e "---\n"
