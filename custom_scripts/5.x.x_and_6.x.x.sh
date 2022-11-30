#!/bin/bash

# 5.1.1
if [[ $(systemctl is-enabled cron) == enabled ]]; then
  echo "5.1.1 Audit Successful"
    echo "---"
  else
  echo "5.1.1 Audit Failed - Performing Hardening"
  systemctl --now enable cron
  echo "5.1.1 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.2
if [[ $(stat /etc/crontab | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.2 Audit Successful"
    echo "---"
    else
    echo "5.1.2 Audit Failed - Performing Hardening"
    chown root:root /etc/crontab
    chmod og-rwx /etc/crontab
    echo "5.1.2 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.3
if [[ $(stat /etc/cron.hourly | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.3 Audit Successful"
    echo "---"
    else
    echo "5.1.3 Audit Failed - Performing Hardening"
    chown root:root /etc/cron.hourly/
    chmod og-rwx /etc/cron.hourly/
    echo "5.1.3 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.4
if [[ $(stat /etc/cron.daily | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.4 Audit Successful"
    echo "---"
    else
    echo "5.1.4 Audit Failed - Performing Hardening"
    chown root:root /etc/cron.daily/
    chmod og-rwx /etc/cron.daily/
    echo "5.1.4 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.5
if [[ $(stat /etc/cron.weekly | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.5 Audit Successful"
    echo "---"
    else
    echo "5.1.5 Audit Failed - Performing Hardening"
    chown root:root /etc/cron.weekly/
    chmod og-rwx /etc/cron.weekly/
    echo "5.1.5 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.6
if [[ $(stat /etc/cron.monthly | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.6 Audit Successful"
    echo "---"
    else
    echo "5.1.6 Audit Failed - Performing Hardening"
    chown root:root /etc/cron.monthly/
    chmod og-rwx /etc/cron.monthly/
    echo "5.1.6 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.7
if [[ $(stat /etc/cron.d | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.7 Audit Successful"
    echo "---"
    else
    echo "5.1.7 Audit Failed - Performing Hardening"
    chown root:root /etc/cron.d/
    chmod og-rwx /etc/cron.d/
    echo "5.1.7 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.8
if [[ $(stat /etc/cron.allow | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.8 Audit Successful"
    echo "---"
    else
    echo "5.1.8 Audit Failed - Performing Hardening"
    rm /etc/cron.deny
    touch /etc/cron.allow
    chmod g-wx,o-rwx /etc/cron.allow
    chown root:root /etc/cron.allow
    echo "5.1.8 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.1.9
if [[ $(stat /etc/at.allow | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.1.9 Audit Successful"
    echo "---"
    else
    echo "5.1.9 Audit Failed - Performing Hardening"
    rm /etc/at.deny
    touch /etc/at.allow
    chmod g-wx,o-rwx /etc/at.allow
    chown root:root /etc/at.allow
    echo "5.1.9 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.1
if [[ $(stat /etc/ssh/sshd_config | grep "Uid: (    0/    root)   Gid: (    0/    root)") == *root* ]]; then
    echo "5.2.1 Audit Successful"
    echo "---"
    else
    echo "5.2.1 Audit Failed - Performing Hardening"
    chown root:root /etc/ssh/sshd_config
    chmod og-rwx /etc/ssh/sshd_config
    echo "5.2.1 Audit Complete - Hardening Complete"
    echo "---"
fi
 
# 5.2.2

output=$(

{
 l_output=""
 l_skgn="ssh_keys" # Group designated to own openSSH keys
 l_skgid="$(awk -F: '($1 == "'"$l_skgn"'"){print $3}' /etc/group)"
 awk '{print}' <<< "$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -L -c "%n %#a %U %G %g" {} +)" | (while read -r l_file l_mode l_owner l_group l_gid; do
 [ -n "$l_skgid" ] && l_cga="$l_skgn" || l_cga="root"
 [ "$l_gid" = "$l_skgid" ] && l_pmask="0137" || l_pmask="0177" l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"
 [ $(( $l_mode & $l_pmask )) -gt 0 ] && l_output="$l_output\n - File: \"$l_file\" is mode \"$l_mode\" should be mode: \"$l_maxperm\" or more restrictive"
 [ "$l_owner" != "root" ] && l_output="$l_output\n - File: \"$l_file\" is owned by: \"$l_owner\" should be owned by \"root\""
 if [ "$l_group" != "root" ] && [ "$l_gid" != "$l_skgid" ]; then
 l_output="$l_output\n - File: \"$l_file\" is owned by group \"$l_group\" should belong to group \"$l_cga\""
 fi
 done
 if [ -z "$l_output" ]; then
 echo -e "\n- Audit Result:\n *** PASS ***\n"
 else
 echo -e "\n- Audit Result:\n *** FAIL ***$l_output\n"
 fi
 )
}

)

if [[ $output == *PASS* ]]; then
    echo "5.2.2 Audit Successful"
    echo "---"
    else
    echo "5.2.2 Audit Failed - Performing Hardening"

 l_skgn="ssh_keys" # Group designated to own openSSH keys
 l_skgid="$(awk -F: '($1 == "'"$l_skgn"'"){print $3}' /etc/group)"
 awk '{print}' <<< "$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat -L -c "%n %#a %U %G %g" {} +)" | (while read -r l_file l_mode l_owner l_group l_gid; do
 [ -n "$l_skgid" ] && l_cga="$l_skgn" || l_cga="root"
 [ "$l_gid" = "$l_skgid" ] && l_pmask="0137" || l_pmask="0177" l_maxperm="$( printf '%o' $(( 0777 & ~$l_pmask )) )"
 if [ $(( $l_mode & $l_pmask )) -gt 0 ]; then
 echo -e " - File: \"$l_file\" is mode \"$l_mode\" changing to mode: \"$l_maxperm\""
 if [ -n "$l_skgid" ]; then
 chmod u-x,g-wx,o-rwx "$l_file"
 else
 chmod u-x,go-rwx "$l_file"
 fi
 fi
 if [ "$l_owner" != "root" ]; then
 echo -e " - File: \"$l_file\" is owned by: \"$l_owner\" changing owner to \"root\""
 chown root "$l_file"
 fi
 if [ "$l_group" != "root" ] && [ "$l_gid" != "$l_skgid" ]; then
 echo -e " - File: \"$l_file\" is owned by group \"$l_group\" should belong to group \"$l_cga\""
 chgrp "$l_cga" "$l_file"
 fi
 done
 )
echo "5.2.2 Audit Complete - Hardening Complete"
fi

# 5.2.3
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod u-x,go-wx {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;
echo "5.2.3 Audit Successful"
    echo "---"


# 5.2.5


if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep loglevel) == *VERBOSE* ]]; then
    echo "5.2.5 Audit Successful"
    echo "---"
    else
    echo "5.2.5 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(LogLevel\s*\).*$/\1 VERBOSE/' /etc/ssh/sshd_config
    echo "5.2.5 Audit Complete - Hardening Complete"
    echo "---"
fi
 
# 5.2.6


if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i usepam) == *yes* ]]; then
    echo "5.2.6 Audit Successful"
    echo "---"
    else
    echo "5.2.6 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(UsePAM\s*\).*$/\1 YES/' /etc/ssh/sshd_config
    echo "5.2.6 Audit Complete - Hardening Complete"
    echo "---"
fi


# 5.2.7


if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep permitrootlogin) == *no* ]]; then
    echo "5.2.7 Audit Successful"
    echo "---"
    else
    echo "5.2.7 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 no/' /etc/ssh/sshd_config
    echo "5.2.7 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.8

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep hostbasedauthentication) == *no* ]]; then
    echo "5.2.8 Audit Successful"
    echo "---"
    else
    echo "5.2.8 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(HostbasedAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config
    echo "5.2.8 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.9


if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep permitemptypasswords) == *no* ]]; then
    echo "5.2.9 Audit Successful"
    echo "---"
    else
    echo "5.2.9 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(PermitEmptyPasswords\s*\).*$/\1 no/' /etc/ssh/sshd_config
    echo "5.2.9 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.10

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep permituserenvironment) == *no* ]]; then
    echo "5.2.10 Audit Successful"
    echo "---"
    else
    echo "5.2.10 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(PermitUserEnvironment\s*\).*$/\1 no/' /etc/ssh/sshd_config
    echo "5.2.10 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.11

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep ignorerhosts) == *no* ]]; then
    echo "5.2.11 Audit Successful"
    echo "---"
    else
    echo "5.2.11 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(IgnoreRhosts\s*\).*$/\1 no/' /etc/ssh/sshd_config
    echo "5.2.11 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.12

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i x11forwarding) == *no* ]]; then
    echo "5.2.12 Audit Successful"
    echo "---"
    else
    echo "5.2.12 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(X11Forwarding\s*\).*$/\1 no/' /etc/ssh/sshd_config
    echo "5.2.12 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.13

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep ciphers) == *chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com* ]]; then
    echo "5.2.13 Audit Successful"
    echo "---"
    else
    echo "5.2.13 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(Ciphers\s*\).*$/\1 chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com/' /etc/ssh/sshd_config
    echo "5.2.13 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.16

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i allowtcpforwarding) == *no* ]]; then
    echo "5.2.16 Audit Successful"
    echo "---"
    else
    echo "5.2.16 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(AllowTcpForwarding\s*\).*$/\1 no/' /etc/ssh/sshd_config
    echo "5.2.16 Audit Complete - Hardening Complete"
    echo "---"
fi


# 5.2.18

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep maxauthtries) == *4* ]]; then
    echo "5.2.18 Audit Successful"
    echo "---"
    else
    echo "5.2.18 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(MaxAuthTries\s*\).*$/\1 4/' /etc/ssh/sshd_config
    echo "5.2.18 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.19

if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i maxstartups) == *10:30:60* ]]; then
    echo "5.2.19 Audit Successful"
    echo "---"
    else
    echo "5.2.19 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(MaxStartups\s*\).*$/\1 10:30:60/' /etc/ssh/sshd_config
    echo "5.2.19 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.2.22
if [[ $(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep clientaliveinterval) == *clientaliveinterval* ]]; then
    echo "5.2.22 Audit Successful"
    echo "---"
    else
    echo "5.2.22 Audit Failed - Performing Hardening"
    sed -i 's/#\?\(ClientAliveInterval\s*\).*$/\1 15/' /etc/ssh/sshd_config
    sed -i 's/#\?\(ClientAliveCountMax\s*\).*$/\1 3/' /etc/ssh/sshd_config
    echo "5.2.22 Audit Complete - Hardening Complete"
    echo "---"
fi

# 5.5.3
if [[ $(grep "^root:" /etc/passwd | cut -f4 -d:) == *0* ]]; then
    echo "5.5.3 Audit Successful"
    echo "---"
    else
    echo "5.5.3 Audit Failed - Performing Hardening"
    usermod -g 0 root

    echo "5.5.3 Audit Complete - Hardening Complete"
    echo "---"
fi
# SSH Daemon reload
systemctl reload sshd


# 6.1.1 
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/passwd | grep "0/root") == *root* ]]; then
    echo "6.1.1 Audit Successful"
    echo "---"
    else
    echo "6.1.1   Audit Failed - Performing Hardening"
    chmod u-x,go-wx /etc/passwd
    chown root:root /etc/passwd

    echo "6.1.1  Audit Complete - Hardening Complete"
    echo "---"
fi

#  6.1.2
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/passwd- | grep "0/root") == *root* ]]; then
    echo "6.1.2 Audit Successful"
    echo "---"
    else
    echo "6.1.2 Audit Failed - Performing Hardening"

    chmod u-x,go-wx /etc/passwd-
    chown root:root /etc/passwd-
    echo "6.1.2 Audit Complete - Hardening Complete"
    echo "---"
fi

# 6.1.3
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/group | grep "0/root") == *root* ]]; then
    echo "6.1.3 Audit Successful"
    echo "---"
    else
    echo "6.1.3 Audit Failed - Performing Hardening"
    chmod u-x,go-wx /etc/group
    chown root:root /etc/group
    echo "6.1.3 Audit Complete - Hardening Complete"
    echo "---"
fi

# 6.1.4
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/group- | grep "0/root") == *root* ]]; then
    echo "6.1.4 Audit Successful"
    echo "---"
    else
    echo "6.1.4 Audit Failed - Performing Hardening"
    chmod u-x,go-wx /etc/group-
    chown root:root /etc/group-
    echo "6.1.4 Audit Complete - Hardening Complete"
    echo "---"
fi

# 6.1.5
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/shadow | grep "0/root") == *root* ]]; then
    echo "6.1.5 Audit Successful"
    echo "---"
    else
    echo "6.1.5 Audit Failed - Performing Hardening"
    chown root:root /etc/shadow
    echo "6.1.5 Audit Complete - Hardening Complete"
    echo "---"
fi

# 6.1.6
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/shadow- | grep "0/root") == *root* ]]; then
    echo "6.1.6 Audit Successful"
    echo "---"
    else
    echo "6.1.6 Audit Failed - Performing Hardening"
    chown root:root /etc/shadow-
    echo "6.1.6 Audit Complete - Hardening Complete"
    echo "---"
fi

# 6.1.7
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/gshadow | grep "0/root") == *root* ]]; then
    echo "6.1.7 Audit Successful"
    echo "---"
    else
    echo "6.1.7 Audit Failed - Performing Hardening"
    chown root:root /etc/gshadow
    echo "6.1.7 Audit Complete - Hardening Complete"
    echo "---"
fi

# 6.1.8
if [[ $(stat -Lc "%n %a %u/%U %g/%G" /etc/gshadow- | grep "0/root") == *root* ]]; then
    echo "6.1.8 Audit Successful"
    echo "---"
    else
    echo "6.1.8 Audit Failed - Performing Hardening"
    chown root:root /etc/gshadow-
    echo "6.1.8 Audit Complete - Hardening Complete"
    echo "---"
fi