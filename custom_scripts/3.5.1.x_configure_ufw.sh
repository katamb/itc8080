#!/bin/bash

echo "3.5.1.1 Ensure ufw is installed"
if [ "$(dpkg-query -W -f='${db:Status-Status}' ufw)" == "installed" ]; then
  echo -e "\n- Audit Result:\n ** PASS **\nUFW is installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nUFW not installed\n"

  echo "Remediating"
  apt install ufw
fi

echo "3.5.1.2 Ensure iptables-persistent is not installed with ufw"
# todo needs attention
if [[ "$(dpkg-query -s iptables-persistent)" == *"not installed"* ]]; then
  echo -e "\n- Audit Result:\n ** PASS **\niptables-persistent is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\niptables-persistent is installed\n"

  echo "Remediating"
  apt purge iptables-persistent
fi

echo "3.5.1.3 Ensure ufw service is enabled"
if [ "$(systemctl is-enabled ufw.service)" == "enabled" ]; then
  echo -e "\n- UFW enabled\n"
else
  echo -e "\n- UFW not enabled, enabling\n"
  systemctl unmask ufw.service
fi

if [ "$(systemctl is-active ufw)" == "active" ]; then
  echo -e "\n- UFW daemon active\n"
else
  echo -e "\n- UFW daemon not active, enabling\n"
  systemctl --now enable ufw.service
fi

if [ "$(ufw status)" == "Status: active" ]; then
  echo -e "\n- UFW daemon active\n"
else
  echo -e "\n- UFW daemon not active, enabling\n"
  ufw enable
fi

echo "3.5.1.4 Ensure ufw loopback traffic is configured"
if [[ "$(ufw status verbose | tr -s ' ' | grep -c 'Anywhere on lo ALLOW IN Anywhere')" != 0 ]]; then
  echo -e "\nufw allow in on lo is configured\n"
else
  echo -e "\nufw allow in on lo is not configured - configuring\n"

  echo "Remediating"
  ufw allow in on lo
fi
if [[ "$(ufw status verbose | tr -s ' ' | grep -c 'Anywhere DENY IN 127.0.0.0/8')" != 0 ]]; then
  echo -e "\nufw deny in from 127.0.0.0/8 is configured\n"
else
  echo -e "\nufw deny in from 127.0.0.0/8 is not configured - configuring\n"

  echo "Remediating"
  ufw deny in from 127.0.0.0/8
fi
if [[ "$(ufw status verbose | tr -s ' ' | grep -c 'Anywhere ALLOW OUT Anywhere on lo')" != 0 ]]; then
  echo -e "\nufw allow out on lo is configured\n"
else
  echo -e "\nufw allow out on lo is not configured - configuring\n"

  echo "Remediating"
  ufw allow out on lo
fi
if [[ "$(ufw status verbose | tr -s ' ' | grep -c 'Anywhere (v6) DENY IN ::1')" != 0 ]]; then
  echo -e "\nufw deny in from ::1 is configured\n"
else
  echo -e "\nufw deny in from ::1 is not configured - configuring\n"

  echo "Remediating"
  ufw deny in from ::1
fi

echo "3.5.1.5 Ensure ufw outbound connections are configured"
echo "No need in current context"

echo "3.5.1.6 Ensure ufw firewall rules exist for all open ports"
ufw_out="$(ufw status verbose)"
ss -tuln | awk '($5!~/%lo:/ && $5!~/127.0.0.1:/ && $5!~/::1/) {split($5, a,":"); print a[2]}' | sort | uniq | while read -r lpn; do
 ! grep -Pq "^\h*$lpn\b" <<< "$ufw_out" && echo "- Port: \"$lpn\" is missing a firewall rule"
 echo "Adding rule"
 ufw allow in "$lpn"
done
