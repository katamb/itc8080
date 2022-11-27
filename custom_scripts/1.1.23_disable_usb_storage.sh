#!/bin/

# todo needs rework
touch /etc/modprobe.d/usb-storage.conf
echo "install usb-storage /bin/true" > /etc/modprobe.d/usb-storage.conf
/sbin/rmmod usb-storage
