#!/bin/bash

fix_banner() {
  l_pkgoutput=""
  if command -v dpkg-query >/dev/null 2>&1; then
    l_pq="dpkg-query -W"
  elif command -v rpm >/dev/null 2>&1; then
    l_pq="rpm -q"
  fi
  l_pcl="gdm gdm3" # Space seporated list of packages to check
  for l_pn in $l_pcl; do
    $l_pq "$l_pn" >/dev/null 2>&1 && l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
  done
  if [ -n "$l_pkgoutput" ]; then
    l_gdmprofile="gdm" # Set this to desired profile name IaW Local site
    policy
    l_bmessage="'Authorized uses only. All activity may be monitored and reported'" # Set to desired banner message
    if [ ! -f "/etc/dconf/profile/$l_gdmprofile" ]; then
      echo "Creating profile \"$l_gdmprofile\""
      echo -e "user-db:user\nsystem-db:$l_gdmprofile\nfiledb:/usr/share/$l_gdmprofile/greeter-dconf-defaults" >/etc/dconf/profile/$l_gdmprofile
    fi
    if [ ! -d "/etc/dconf/db/$l_gdmprofile.d/" ]; then
      echo "Creating dconf database directory \"/etc/dconf/db/$l_gdmprofile.d/\""
      mkdir /etc/dconf/db/$l_gdmprofile.d/
    fi
    if
      ! grep -Piq '^\h*banner-message-enable\h*=\h*true\b' /etc/dconf/db/$l_gdmprofile.d/*
    then
      echo "creating gdm keyfile for machine-wide settings"
      if
        ! grep -Piq -- '^\h*banner-message-enable\h*=\h*' /etc/dconf/db/$l_gdmprofile.d/*
      then
        l_kfile="/etc/dconf/db/$l_gdmprofile.d/01-banner-message"
        echo -e "\n[org/gnome/login-screen]\nbanner-message-enable=true" >>"$l_kfile"
      else
        l_kfile="$(grep -Pil -- '^\h*banner-message-enable\h*=\h*' /etc/dconf/db/$l_gdmprofile.d/*)"
        ! grep -Pq '^\h*\[org\/gnome\/login-screen\]' "$l_kfile" && sed - ri '/^\s*banner-message-enable/ i\[org/gnome/login-screen]' "$l_kfile"
        ! grep -Pq '^\h*banner-message-enable\h*=\h*true\b' "$l_kfile" && sed -ri 's/^\s*(banner-message-enable\s*=\s*)(\S+)(\s*.*$)/\1true \3//' "$l_kfile"
        # sed -ri '/^\s*\[org\/gnome\/login-screen\]/ a\\nbanner-messageenable=true' "$l_kfile"
      fi
    fi
    if ! grep -Piq "^\h*banner-message-text=[\'\"]+\S+" "$l_kfile"; then
      sed -ri "/^\s*banner-message-enable/ a\banner-messagetext=$l_bmessage" "$l_kfile"
    fi
    dconf update
  else
    echo -e "\n\n - GNOME Desktop Manager isn't installed\n - Recommendation is Not Applicable\n - No remediation required\n"
  fi
}

audit_banner() {
  l_pkgoutput=""
  if command -v dpkg-query >/dev/null 2>&1; then
    l_pq="dpkg-query -W"
  elif command -v rpm >/dev/null 2>&1; then
    l_pq="rpm -q"
  fi
  l_pcl="gdm gdm3" # Space seporated list of packages to check
  for l_pn in $l_pcl; do
    $l_pq "$l_pn" >/dev/null 2>&1 && l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
  done
  if [ -n "$l_pkgoutput" ]; then
    l_output="" l_output2=""
    echo -e "$l_pkgoutput"
    # Look for existing settings and set variables if they exist
    l_gdmfile="$(grep -Prils '^\h*banner-message-enable\b' /etc/dconf/db/*.d)"
    if [ -n "$l_gdmfile" ]; then
      # Set profile name based on dconf db directory ({PROFILE_NAME}.d)
      l_gdmprofile="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_gdmfile")"
      # Check if banner message is enabled
      if grep -Pisq '^\h*banner-message-enable=true\b' "$l_gdmfile"; then
        l_output="$l_output\n - The \"banner-message-enable\" option is enabled in \"$l_gdmfile\""
      else
        l_output2="$l_output2\n - The \"banner-message-enable\" option is not enabled"
      fi
      l_lsbt="$(grep -Pios '^\h*banner-message-text=.*$' "$l_gdmfile")"
      if [ -n "$l_lsbt" ]; then
        l_output="$l_output\n - The \"banner-message-text\" option is set in \"$l_gdmfile\"\n - banner-message-text is set to:\n - \"$l_lsbt\""
      else
        l_output2="$l_output2\n - The \"banner-message-text\" option is not set"
      fi
      if
        grep -Pq "^\h*system-db:$l_gdmprofile" /etc/dconf/profile/"$l_gdmprofile"
      then
        l_output="$l_output\n - The \"$l_gdmprofile\" profile exists"
      else
        l_output2="$l_output2\n - The \"$l_gdmprofile\" profile doesn't exist"
      fi
      if [ -f "/etc/dconf/db/$l_gdmprofile" ]; then
        l_output="$l_output\n - The \"$l_gdmprofile\" profile exists in the dconf database"
      else
        l_output2="$l_output2\n - The \"$l_gdmprofile\" profile doesn't exist in the dconf database"
      fi
    else
      l_output2="$l_output2\n - The \"banner-message-enable\" option isn't configured"
    fi
  else
    echo -e "\n\n - GNOME Desktop Manager isn't installed\n - Recommendation is Not Applicable\n- Audit result:\n *** PASS ***\n"
  fi
  # Report results. If no failures output in l_output2, we pass
  if [ -z "$l_output2" ]; then
    echo -e "\n- Audit Result:\n ** PASS **\n$l_output\n"
  else
    echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n"
    echo "Remediating"
    fix_banner
  fi
}

echo "---"
echo "1.8.2 Ensure GDM login banner is configured"
#audit_banner
echo "Skipping"
echo -e "---\n"

fix_user_list() {
  l_gdmprofile="gdm"
  if [ ! -f "/etc/dconf/profile/$l_gdmprofile" ]; then
    echo "Creating profile \"$l_gdmprofile\""
    echo -e "user-db:user\nsystem-db:$l_gdmprofile\nfiledb:/usr/share/$l_gdmprofile/greeter-dconf-defaults" >/etc/dconf/profile/$l_gdmprofile
  fi
  if [ ! -d "/etc/dconf/db/$l_gdmprofile.d/" ]; then
    echo "Creating dconf database directory \"/etc/dconf/db/$l_gdmprofile.d/\""
    mkdir /etc/dconf/db/$l_gdmprofile.d/
  fi
  if
    ! grep -Piq '^\h*disable-user-list\h*=\h*true\b' /etc/dconf/db/$l_gdmprofile.d/*
  then
    echo "creating gdm keyfile for machine-wide settings"
    if
      ! grep -Piq -- '^\h*\[org\/gnome\/login-screen\]' /etc/dconf/db/$l_gdmprofile.d/*
    then
      echo -e "\n[org/gnome/login-screen]\n# Do not show the user
                list\ndisable-user-list=true" >>/etc/dconf/db/$l_gdmprofile.d/00-loginscreen
    else
      sed -ri '/^\s*\[org\/gnome\/login-screen\]/ a\# Do not show the user list\ndisable-user-list=true' $(grep -Pil -- '^\h*\[org\/gnome\/loginscreen\]' /etc/dconf/db/$l_gdmprofile.d/*)
    fi
  fi
  dconf update
}

audit_user_list() {
  l_pkgoutput=""
  if command -v dpkg-query >/dev/null 2>&1; then
    l_pq="dpkg-query -W"
  elif command -v rpm >/dev/null 2>&1; then
    l_pq="rpm -q"
  fi
  l_pcl="gdm gdm3" # Space seporated list of packages to check
  for l_pn in $l_pcl; do
    $l_pq "$l_pn" >/dev/null 2>&1 && l_pkgoutput="$l_pkgoutput\n -
                  Package: \"$l_pn\" exists on the system\n - checking configuration"
  done
  if [ -n "$l_pkgoutput" ]; then
    output="" output2=""
    l_gdmfile="$(grep -Pril '^\h*disable-user-list\h*=\h*true\b' /etc/dconf/db)"
    if [ -n "$l_gdmfile" ]; then
      output="$output\n - The \"disable-user-list\" option is enabled in \"$l_gdmfile\""
      l_gdmprofile="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_gdmfile")"
      if
        grep -Pq "^\h*system-db:$l_gdmprofile" /etc/dconf/profile/"$l_gdmprofile"
      then
        output="$output\n - The \"$l_gdmprofile\" exists"
      else
        output2="$output2\n - The \"$l_gdmprofile\" doesn't exist"
      fi
      if [ -f "/etc/dconf/db/$l_gdmprofile" ]; then
        output="$output\n - The \"$l_gdmprofile\" profile exists in the dconf database"
      else
        output2="$output2\n - The \"$l_gdmprofile\" profile doesn't exist in the dconf database"
      fi
    else
      output2="$output2\n - The \"disable-user-list\" option is not enabled"
    fi
    if [ -z "$output2" ]; then
      echo -e "$l_pkgoutput\n- Audit result:\n *** PASS: ***\n$output\n"
    else
      echo -e "$l_pkgoutput\n- Audit Result:\n *** FAIL: ***\n$output2\n"
      [ -n "$output" ] && echo -e "$output\n"
      echo "Remediating"
      fix_user_list
    fi
  else
    echo -e "\n\n - GNOME Desktop Manager isn't installed\n - Recommendation is Not Applicable\n- Audit result:\n *** PASS ***\n"
  fi
}

echo "---"
echo "1.8.3 Ensure GDM disable-user-list option is enabled"
#audit_user_list
echo "Skipping"
echo -e "---\n"

fix_auto_m() {
  l_pkgoutput="" l_output="" l_output2=""
  l_gpbame="local" # Set to desired dconf profile name (defaule is local)
  # Check if GNOME Desktop Manager is installed. If package isn't installed, recommendation is Not Applicable\n
  # determine system's package manager
  if command -v dpkg-query >/dev/null 2>&1; then
    l_pq="dpkg-query -W"
  elif command -v rpm >/dev/null 2>&1; then
    l_pq="rpm -q"
  fi
  # Check if GDM is installed
  l_pcl="gdm gdm3" # Space seporated list of packages to check
  for l_pn in $l_pcl; do
    $l_pq "$l_pn" >/dev/null 2>&1 && l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
  done
  echo -e "$l_packageout"
  # Check configuration (If applicable)
  if [ -n "$l_pkgoutput" ]; then
    echo -e "$l_pkgoutput"
    # Look for existing settings and set variables if they exist
    l_kfile="$(grep -Prils -- '^\h*automount\b' /etc/dconf/db/*.d)"
    l_kfile2="$(grep -Prils -- '^\h*automount-open\b' /etc/dconf/db/*.d)"
    # Set profile name based on dconf db directory ({PROFILE_NAME}.d)
    if [ -f "$l_kfile" ]; then
      l_gpname="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_kfile")"
      echo " - updating dconf profile name to \"$l_gpname\""
    elif [ -f "$l_kfile2" ]; then
      l_gpname="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_kfile2")"
      echo " - updating dconf profile name to \"$l_gpname\""
    fi
    # check for consistency (Clean up configuration if needed)
    if [ -f "$l_kfile" ] && [ "$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_kfile")" != "$l_gpname" ]; then
      sed -ri "/^\s*automount\s*=/s/^/# /" "$l_kfile"
      l_kfile="/etc/dconf/db/$l_gpname.d/00-media-automount"
    fi
    if [ -f "$l_kfile2" ] && [ "$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_kfile2")" != "$l_gpname" ]; then
      sed -ri "/^\s*automount-open\s*=/s/^/# /" "$l_kfile2"
    fi
    [ -n "$l_kfile" ] && l_kfile="/etc/dconf/db/$l_gpname.d/00-mediaautomount"
    # Check if profile file exists
    if grep -Pq -- "^\h*system-db:$l_gpname\b" /etc/dconf/profile/*; then
      echo -e "\n - dconf database profile exists in: \"$(grep -Pl -- "^\h*system-db:$l_gpname\b" /etc/dconf/profile/*)\""
    else
      [ ! -f "/etc/dconf/profile/user" ] && l_gpfile="/etc/dconf/profile/user" || l_gpfile="/etc/dconf/profile/user2"
      echo -e " - creating dconf database profile"
      {
        echo -e "\nuser-db:user"
        echo "system-db:$l_gpname"
      } >>"$l_gpfile"
    fi
    # create dconf directory if it doesn't exists
    l_gpdir="/etc/dconf/db/$l_gpname.d"
    if [ -d "$l_gpdir" ]; then
      echo " - The dconf database directory \"$l_gpdir\" exists"
    else
      echo " - creating dconf database directory \"$l_gpdir\""
      mkdir "$l_gpdir"
    fi
    # check automount-open setting
    if grep -Pqs -- '^\h*automount-open\h*=\h*false\b' "$l_kfile"; then
      echo " - \"automount-open\" is set to false in: \"$l_kfile\""
    else
      echo " - creating \"automount-open\" entry in \"$l_kfile\""
      ! grep -Psq -- '\^\h*\[org\/gnome\/desktop\/media-handling\]\b' "$l_kfile" && echo '[org/gnome/desktop/media-handling]' >>"$l_kfile"
      sed -ri '/^\s*\[org\/gnome\/desktop\/media-handling\]/a \\nautomount-open=false'
    fi
    # check automount setting
    if grep -Pqs -- '^\h*automount\h*=\h*false\b' "$l_kfile"; then
      echo " - \"automount\" is set to false in: \"$l_kfile\""
    else
      echo " - creating \"automount\" entry in \"$l_kfile\""
      ! grep -Psq -- '\^\h*\[org\/gnome\/desktop\/media-handling\]\b' "$l_kfile" && echo '[org/gnome/desktop/media-handling]' >>"$l_kfile"
      sed -ri '/^\s*\[org\/gnome\/desktop\/media-handling\]/a \\nautomount=false'
    fi
  else
    echo -e "\n - GNOME Desktop Manager package is not installed on the system\n - Recommendation is not applicable"
  fi
  # update dconf database
  dconf update
}

audit_auto_m() {
  l_pkgoutput="" l_output="" l_output2=""
  # Check if GNOME Desktop Manager is installed. If package isn't installed, recommendation is Not Applicable\n
  # determine system's package manager
  if command -v dpkg-query >/dev/null 2>&1; then
    l_pq="dpkg-query -W"
  elif command -v rpm >/dev/null 2>&1; then
    l_pq="rpm -q"
  fi
  # Check if GDM is installed
  l_pcl="gdm gdm3" # Space seporated list of packages to check
  for l_pn in $l_pcl; do
    $l_pq "$l_pn" >/dev/null 2>&1 && l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
  done
  # Check configuration (If applicable)
  if [ -n "$l_pkgoutput" ]; then
    echo -e "$l_pkgoutput"
    # Look for existing settings and set variables if they exist
    l_kfile="$(grep -Prils -- '^\h*automount\b' /etc/dconf/db/*.d)"
    l_kfile2="$(grep -Prils -- '^\h*automount-open\b' /etc/dconf/db/*.d)"
    # Set profile name based on dconf db directory ({PROFILE_NAME}.d)
    if [ -f "$l_kfile" ]; then
      l_gpname="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_kfile")"
    elif [ -f "$l_kfile2" ]; then
      l_gpname="$(awk -F\/ '{split($(NF-1),a,".");print a[1]}' <<<"$l_kfile2")"
    fi
    # If the profile name exist, continue checks
    if [ -n "$l_gpname" ]; then
      l_gpdir="/etc/dconf/db/$l_gpname.d"
      # Check if profile file exists
      if grep -Pq -- "^\h*system-db:$l_gpname\b" /etc/dconf/profile/*; then
        l_output="$l_output\n - dconf database profile file \"$(grep -Pl -- "^\h*system-db:$l_gpname\b" /etc/dconf/profile/*)\" exists"
      else
        l_output2="$l_output2\n - dconf database profile isn't set"
      fi
      # Check if the dconf database file exists
      if [ -f "/etc/dconf/db/$l_gpname" ]; then
        l_output="$l_output\n - The dconf database \"$l_gpname\" exists"
      else
        l_output2="$l_output2\n - The dconf database \"$l_gpname\" doesn't exist"
      fi
      # check if the dconf database directory exists
      if [ -d "$l_gpdir" ]; then
        l_output="$l_output\n - The dconf directory \"$l_gpdir\" exits"
      else
        l_output2="$l_output2\n - The dconf directory \"$l_gpdir\" doesn't exist"
      fi
      # check automount setting
      if grep -Pqrs -- '^\h*automount\h*=\h*false\b' "$l_kfile"; then
        l_output="$l_output\n - \"automount\" is set to false in: \"$l_kfile\""
      else
        l_output2="$l_output2\n - \"automount\" is not set correctly"
      fi
      # check automount-open setting
      if grep -Pqs -- '^\h*automount-open\h*=\h*false\b' "$l_kfile2"; then
        l_output="$l_output\n - \"automount-open\" is set to false in: \"$l_kfile2\""
      else
        l_output2="$l_output2\n - \"automount-open\" is not set correctly"
      fi
    else
      # Setings don't exist. Nothing further to check
      l_output2="$l_output2\n - neither \"automount\" or \"automountopen\" is set"
    fi
  else
    l_output="$l_output\n - GNOME Desktop Manager package is not installed on the system\n - Recommendation is not applicable"
  fi
  # Report results. If no failures output in l_output2, we pass
  if [ -z "$l_output2" ]; then
    echo -e "\n- Audit Result:\n ** PASS **\n$l_output\n"
  else
    echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n"

    echo "Remediating"
    fix_auto_m
  fi
}

echo "---"
echo "1.8.6 Ensure GDM automatic mounting of removable media is disabled"
audit_auto_m
echo -e "---\n"

fix_auto_mount() {
  # Check if GNMOE Desktop Manager is installed. If package isn't installed, recommendation is Not Applicable\n
  # determine system's package manager
  mkdir -p /org/gnome/desktop/media-handling/automount
  mkdir -p /org/gnome/desktop/media-handling/automount-open
  l_pkgoutput=""
  if command -v dpkg-query >/dev/null 2>&1; then
    l_pq="dpkg-query -W"
  elif command -v rpm >/dev/null 2>&1; then
    l_pq="rpm -q"
  fi
  # Check if GDM is installed
  l_pcl="gdm gdm3" # Space seporated list of packages to check
  for l_pn in $l_pcl; do
    $l_pq "$l_pn" >/dev/null 2>&1 && l_pkgoutput="y" && echo -e "\n - Package: \"$l_pn\" exists on the system\n - remediating configuration if needed"
  done
  # Check configuration (If applicable)
  if [ -n "$l_pkgoutput" ]; then
    # Look for automount to determine profile in use, needed for remaining tests
    l_kfd="/etc/dconf/db/$(grep -Psril '^\h*automount\b' /etc/dconf/db/*/ |
      awk -F'/' '{split($(NF-1),a,".");print a[1]}').d" #set directory of key file to be locked
    # Look for automount-open to determine profile in use, needed for remaining tests
    l_kfd2="/etc/dconf/db/$(grep -Psril '^\h*automount-open\b' /etc/dconf/db/*/ | awk -F'/' '{split($(NF-1),a,".");print a[1]}').d" #set directory of key file to be locked
    if [ -d "$l_kfd" ]; then                                                                                                        # If key file directory doesn't exist, options can't be locked
      if grep -Priq '^\h*\/org/gnome\/desktop\/mediahandling\/automount\b' "$l_kfd"; then
        echo " - \"automount\" is locked in \"$(grep -Pril '^\h*\/org/gnome\/desktop\/media-handling\/automount\b' "$l_kfd")\""
      else
        echo " - creating entry to lock \"automount\""
        [ ! -d "$l_kfd"/locks ] && echo "creating directory $l_kfd/locks" && mkdir "$l_kfd"/locks
        {
          echo -e '\n# Lock desktop media-handling automount setting'
          echo '/org/gnome/desktop/media-handling/automount'
        } >>"$l_kfd"/locks/00-media-automount
      fi
    else
      echo -e " - \"automount\" is not set so it can not be locked\n - Please follow Recommendation \"Ensure GDM automatic mounting of removable media is disabled\" and follow this Recommendation again"
    fi
    if [ -d "$l_kfd2" ]; then # If key file directory doesn't exist, options can't be locked
      if grep -Priq '^\h*\/org/gnome\/desktop\/media-handling\/automountopen\b' "$l_kfd2"; then
        echo " - \"automount-open\" is locked in \"$(grep -Pril '^\h*\/org/gnome\/desktop\/media-handling\/automount-open\b' "$l_kfd2")\""
      else
        echo " - creating entry to lock \"automount-open\""
        [ ! -d "$l_kfd2"/locks ] && echo "creating directory $l_kfd2/locks" && mkdir "$l_kfd2"/locks
        {
          echo -e '\n# Lock desktop media-handling automount-open setting'
          echo '/org/gnome/desktop/media-handling/automount-open'
        } >>"$l_kfd2"/locks/00-media-automount
      fi
    else
      echo -e " - \"automount-open\" is not set so it can not be locked\n - Please follow Recommendation \"Ensure GDM automatic mounting of removable media is disabled\" and follow this Recommendation again"
    fi
    # update dconf database
    dconf update
  else
    echo -e " - GNOME Desktop Manager package is not installed on the system\n - Recommendation is not applicable"
  fi
}

audit_auto_mount() {
  # Check if GNOME Desktop Manager is installed. If package isn't installed, recommendation is Not Applicable\n
  # determine system's package manager
  l_pkgoutput=""
  if command -v dpkg-query >/dev/null 2>&1; then
    l_pq="dpkg-query -W"
  elif command -v rpm >/dev/null 2>&1; then
    l_pq="rpm -q"
  fi
  # Check if GDM is installed
  l_pcl="gdm gdm3" # Space seporated list of packages to check
  for l_pn in $l_pcl; do
    $l_pq "$l_pn" >/dev/null 2>&1 && l_pkgoutput="$l_pkgoutput\n - Package: \"$l_pn\" exists on the system\n - checking configuration"
  done
  # Check configuration (If applicable)
  if [ -n "$l_pkgoutput" ]; then
    l_output="" l_output2=""
    # Look for idle-delay to determine profile in use, needed for remaining tests
    l_kfd="/etc/dconf/db/$(grep -Psril '^\h*automount\b' /etc/dconf/db/*/ | awk -F'/' '{split($(NF-1),a,".");print a[1]}').d"       #set directory of key file to be locked
    l_kfd2="/etc/dconf/db/$(grep -Psril '^\h*automount-open\b' /etc/dconf/db/*/ | awk -F'/' '{split($(NF-1),a,".");print a[1]}').d" #set directory of key file to be locked
    if [ -d "$l_kfd" ]; then                                                                                                        # If key file directory doesn't exist, options can't be locked
      if
        grep -Piq '^\h*\/org/gnome\/desktop\/media-handling\/automount\b' "$l_kfd"
      then
        l_output="$l_output\n - \"automount\" is locked in \"$(grep -Pil '^\h*\/org/gnome\/desktop\/media-handling\/automount\b' "$l_kfd")\""
      else
        l_output2="$l_output2\n - \"automount\" is not locked"
      fi
    else
      l_output2="$l_output2\n - \"automount\" is not set so it can not be locked"
    fi
    if [ -d "$l_kfd2" ]; then # If key file directory doesn't exist, options can't be locked
      if grep -Piq '^\h*\/org/gnome\/desktop\/media-handling\/automountopen\b' "$l_kfd2"; then
        l_output="$l_output\n - \"lautomount-open\" is locked in \"$(grep -Pril '^\h*\/org/gnome\/desktop\/media-handling\/automount-open\b' "$l_kfd2")\""
      else
        l_output2="$l_output2\n - \"automount-open\" is not locked"
      fi
    else
      l_output2="$l_output2\n - \"automount-open\" is not set so it can not be locked"
    fi
  else
    l_output="$l_output\n - GNOME Desktop Manager package is not installed on the system\n - Recommendation is not applicable"
  fi
  # Report results. If no failures output in l_output2, we pass
  [ -n "$l_pkgoutput" ] && echo -e "\n$l_pkgoutput"
  if [ -z "$l_output2" ]; then
    echo -e "\n- Audit Result:\n ** PASS **\n$l_output\n"
  else
    echo -e "\n- Audit Result:\n ** FAIL **\n - Reason(s) for audit failure:\n$l_output2\n"
    [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n"
    fix_auto_mount
  fi
}

echo "---"
echo "1.8.7 Ensure GDM disabling automatic mounting of removable media is not overridden"
audit_auto_mount
echo -e "---\n"
