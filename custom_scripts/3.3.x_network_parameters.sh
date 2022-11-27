#!/bin/bash

remediate() {
  l_output="" l_output2=""
  l_parlist="$1"
  l_searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf $([ -f /etc/default/ufw ] && awk -F= '/^\s*IPT_SYSCTL=/ {print $2}' /etc/default/ufw)"
  KPF() {
    # comment out incorrect parameter(s) in kernel parameter file(s)
    l_fafile="$( grep -s -- "^\s*$l_kpname" $l_searchloc | grep -Pv -- "\h*=\h*$l_kpvalue\b\h*" | awk -F: '{print $1}' )"
    for l_bkpf in $l_fafile; do
      echo -e "\n - Commenting out \"$l_kpname\" in \"$l_bkpf\""
      sed -ri "/$l_kpname/s/^/# /" "$l_bkpf"
    done
    # Set correct parameter in a kernel parameter file
    if
      ! grep -Pslq -- "^\h*$l_kpname\h*=\h*$l_kpvalue\b\h*(#.*)?$" $l_searchloc
    then
      echo -e "\n - Setting \"$l_kpname\" to \"$l_kpvalue\" in \"$l_kpfile\""
      echo "$l_kpname = $l_kpvalue" >>"$l_kpfile"
    fi
    # Set correct parameter in active kernel parameters
    l_krp="$(sysctl "$l_kpname" | awk -F= '{print $2}' | xargs)"
    if [ "$l_krp" != "$l_kpvalue" ]; then
      echo -e "\n - Updating \"$l_kpname\" to \"$l_kpvalue\" in the active kernel parameters"
      sysctl -w "$l_kpname=$l_kpvalue"
      sysctl -w "$(awk -F'.' '{print $1"."$2".route.flush=1"}' <<<"$l_kpname")"
    fi
  }
  IPV6F_CHK() {
    l_ipv6s=""
    grubfile=$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \; )
    if [ -s "$grubfile" ]; then
      ! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && l_ipv6s="disabled"
    fi
    if
      grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" $l_searchloc && grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" $l_searchloc && sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$"
    then
      l_ipv6s="disabled"
    fi
    if [ -n "$l_ipv6s" ]; then
      echo -e "\n - IPv6 is disabled on the system, \"$l_kpname\" is not applicable"
    else
      KPF
    fi
  }
  for l_kpe in $l_parlist; do
    l_kpname="$(awk -F= '{print $1}' <<<"$l_kpe")"
    l_kpvalue="$(awk -F= '{print $2}' <<<"$l_kpe")"
    if grep -q '^net.ipv6.' <<<"$l_kpe"; then
      l_kpfile="/etc/sysctl.d/60-netipv6_sysctl.conf"
      IPV6F_CHK
    else
      l_kpfile="/etc/sysctl.d/60-netipv4_sysctl.conf"
      KPF
    fi
  done
}

audit_and_fix() {
  l_output="" l_output2=""
  l_parlist="$1"
  l_searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf $([ -f /etc/default/ufw ] && awk -F= '/^\s*IPT_SYSCTL=/ {print $2}' /etc/default/ufw)"
  KPC() {
    l_krp="$(sysctl "$l_kpname" | awk -F= '{print $2}' | xargs)"
    l_pafile="$(grep -Psl -- "^\h*$l_kpname\h*=\h*$l_kpvalue\b\h*(#.*)?$" $l_searchloc)"
    l_fafile="$(grep -s -- "^\s*$l_kpname" $l_searchloc | grep -Pv -- "\h*=\h*$l_kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$l_krp" = "$l_kpvalue" ]; then
      l_output="$l_output\n - \"$l_kpname\" is set to \"$l_kpvalue\" in the running configuration"
    else
      l_output2="$l_output2\n - \"$l_kpname\" is set to \"$l_krp\" in the running configuration"
    fi
    if [ -n "$l_pafile" ]; then
      l_output="$l_output\n - \"$l_kpname\" is set to \"$l_kpvalue\" in \"$l_pafile\""
    else
      l_output2="$l_output2\n - \"$l_kpname = $l_kpvalue\" is not set in a kernel parameter configuration file"
    fi
    [ -n "$l_fafile" ] && l_output2="$l_output2\n - \"$l_kpname\" is set incorrectly in \"$l_fafile\""
  }
  ipv6_chk() {
    l_ipv6s=""
    grubfile=$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)
    if [ -s "$grubfile" ]; then
      ! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && l_ipv6s="disabled"
    fi
    if
      grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" $l_searchloc && grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" $l_searchloc && sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$"
    then
      l_ipv6s="disabled"
    fi
    if [ -n "$l_ipv6s" ]; then
      l_output="$l_output\n - IPv6 is disabled on the system, \"$l_kpname\" is not applicable"
    else
      KPC
    fi
  }
  for l_kpe in $l_parlist; do
    l_kpname="$(awk -F= '{print $1}' <<<"$l_kpe")"
    l_kpvalue="$(awk -F= '{print $2}' <<<"$l_kpe")"
    if grep -q '^net.ipv6.' <<<"$l_kpe"; then
      ipv6_chk
    else
      KPC
    fi
  done
  if [ -z "$l_output2" ]; then
    echo -e "\n- Audit Result:\n ** PASS **\n$l_output\n"
  else
    echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n"

    echo "Remediating"
    remediate $l_parlist

  fi
}

# Currently doesn't pass
echo "3.3.1 Ensure source routed packets are not accepted"
audit_and_fix "net.ipv4.conf.all.accept_source_route=0 net.ipv4.conf.default.accept_source_route=0 net.ipv6.conf.all.accept_source_route=0 net.ipv6.conf.default.accept_source_route=0"

# Currently doesn't pass
echo "3.3.2 Ensure ICMP redirects are not accepted"
audit_and_fix "net.ipv4.conf.all.accept_redirects=0 net.ipv4.conf.default.accept_redirects=0 net.ipv6.conf.all.accept_redirects=0 net.ipv6.conf.default.accept_redirects=0"

# Currently doesn't pass
echo "3.3.3 Ensure secure ICMP redirects are not accepted"
audit_and_fix "net.ipv4.conf.default.secure_redirects=0 net.ipv4.conf.all.secure_redirects=0"

# Currently doesn't pass
echo "3.3.4 Ensure suspicious packets are logged"
audit_and_fix "net.ipv4.conf.all.log_martians=1 net.ipv4.conf.default.log_martians=1"

echo "3.3.5 Ensure broadcast ICMP requests are ignored"
audit_and_fix "net.ipv4.icmp_echo_ignore_broadcasts=1"

echo "3.3.6 Ensure bogus ICMP responses are ignored"
audit_and_fix "net.ipv4.icmp_ignore_bogus_error_responses=1"

# Currently doesn't pass
echo "3.3.7 Ensure Reverse Path Filtering is enabled"
audit_and_fix "net.ipv4.conf.all.rp_filter=1 net.ipv4.conf.default.rp_filter=1"

echo "3.3.8 Ensure TCP SYN Cookies is enabled"
audit_and_fix "net.ipv4.tcp_syncookies=1"

# Currently doesn't pass
echo "3.3.9 Ensure IPv6 router advertisements are not accepted"
audit_and_fix "net.ipv6.conf.all.accept_ra=0 net.ipv6.conf.default.accept_ra=0"
