#!/bin/bash

fun151_rem() {
  krp="" pafile="" fafile=""
  kpname="kernel.randomize_va_space"
  kpvalue="2"
  searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
  krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
  pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
  fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
  if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
    echo -e "\nPASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
  else
    echo -e "\nFAIL: "
    [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration\n"
    [ -n "$fafile" ] && echo -e "\n\"$kpname\" is set incorrectly in \"$fafile\""
    [ -z "$pafile" ] && echo -e "\n\"$kpname = $kpvalue\" is not set in a kernel parameter configuration file\n"
  fi
}

fun151() {
  krp="" pafile="" fafile=""
  kpname="kernel.randomize_va_space"
  kpvalue="2"
  searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
  krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
  pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
  fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
  if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
    echo -e "\nPASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
  else
    echo -e "\nFAIL: "
    [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration\n"
    [ -n "$fafile" ] && echo -e "\n\"$kpname\" is set incorrectly in \"$fafile\""
    [ -z "$pafile" ] && echo -e "\n\"$kpname = $kpvalue\" is not set in a kernel parameter configuration file\n"

    echo "Remediating"
    printf "
    kernel.randomize_va_space = 2
    " >> /etc/sysctl.d/60-kernel_sysctl.conf
    sysctl -w kernel.randomize_va_space=2
  fi
}

echo "---"
echo "1.5.1 Ensure address space layout randomization (ASLR) is enabled"
fun151
echo -e "---\n"

echo "---"
echo "1.5.2 Ensure prelink is not installed"
if [[ "$(dpkg-query -s prelink 2>&1)" == *"not installed"* ]]; then
  echo -e "\n- Audit Result:\n ** PASS **\nprelink is not installed\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nprelink is installed\n"

  echo "Remediating"
  prelink -ua
  apt purge prelink
fi
echo -e "---\n"

echo "---"
echo "1.5.3 Ensure Automatic Error Reporting is not enabled"
if [[ "$(dpkg-query -s apport > /dev/null 2>&1 && grep -Psi -- '^\h*enabled\h*=\h*[^0]\b' /etc/default/apport)" == "" ]]; then
  echo -e "\n- Audit Result:\n ** PASS **\nAutomatic Error Reporting is not enabled\n"
else
  echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\nAutomatic Error Reporting is enabled\n"

  echo "Remediating"
  systemctl stop apport.service
  systemctl --now disable apport.service
fi
echo -e "---\n"

