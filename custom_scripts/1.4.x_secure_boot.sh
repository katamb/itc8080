#!/bin/bash

echo "---"
echo "1.4.1 Ensure bootloader password is set"
echo "NOT DOING - requires setting a password"
echo -e "---\n"

echo "---"
echo "1.4.2 Ensure permissions on bootloader config are configured "
if [ "$(stat /boot/grub/grub.cfg | grep -c 0400)" == 1 ] && [ "$(stat /boot/grub/grub.cfg | tr -s ' ' | grep -c 'Uid: ( 0/ root) Gid: ( 0/ root)')" == 1 ]; then
  echo -e "Bootloader correctly configured\n"
else
  echo -e "Bootloader incorrectly configured, remediating\n"
   chown root:root /boot/grub/grub.cfg
   chmod u-wx,go-rwx /boot/grub/grub.cfg
fi
echo -e "---\n"
