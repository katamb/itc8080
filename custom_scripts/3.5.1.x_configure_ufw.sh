#!/bin/bash

echo "3.5.1.1 Ensure ufw is installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' ufw)" != "installed" ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nUFW is installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nUFW not installed\n"

  echo "Remediating"
  apt install ufw
fi

echo "3.5.1.2 Ensure iptables-persistent is not installed with ufw"
not_installed="package 'iptables-persistent' is not installed and no information is available"
if [ "$(dpkg-query -s iptables-persistent)" == "$not_installed" ]; then
  echo -e "\n- Audit Result:\n ** PASS **\niptables-persistent is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\niptables-persistent is installed\n"

  echo "Remediating"
  apt purge iptables-persistent
fi

echo "3.5.1.3 Ensure ufw service is enabled"
if [ "$(systemctl is-enabled ufw.service)" == "enabled" ]; then
  ufw_enabled="$(true)"
  echo -e "\n- UFW enabled\n"
else
  ufw_enabled="$(false)"
  echo -e "\n- UFW not enabled, enabling\n"
  systemctl unmask ufw.service
fi

if [ "$(systemctl is-active ufw)" == "active" ]; then
  ufw_daemon_active="$(true)"
  echo -e "\n- UFW daemon active\n"
else
  ufw_daemon_active="$(false)"
  echo -e "\n- UFW daemon not active, enabling\n"
  systemctl --now enable ufw.service
fi

if [ "$(ufw status)" == "Status: active" ]; then
  ufw_daemon_active="$(true)"
  echo -e "\n- UFW daemon active\n"
else
  ufw_daemon_active="$(false)"
  echo -e "\n- UFW daemon not active, enabling\n"
  ufw enable
fi

#echo "3.5.1.4 Ensure ufw loopback traffic is configured"
#not_installed="package 'iptables-persistent' is not installed and no information is available"
#if [ "$(dpkg-query -s iptables-persistent)" == "$not_installed" ]; then
  #echo -e "\n- Audit Result:\n ** PASS **\niptables-persistent is not installed\n"
#else
  #echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\niptables-persistent is installed\n"

  #echo "Remediating"
  #apt purge iptables-persistent
#fi
