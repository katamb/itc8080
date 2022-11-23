#!/bin/bash
touch /etc/modprobe.d/cramfs.conf
echo "install cramfs /bin/true" > /etc/modprobe.d/cramfs.conf
/sbin/rmmod cramfs

touch /etc/modprobe.d/freevxfs.conf
echo "install freevxfs /bin/true" > /etc/modprobe.d/freevxfs.conf
/sbin/rmmod freevxfs

touch /etc/modprobe.d/jffs2.conf
echo "install jffs2 /bin/true" > /etc/modprobe.d/jffs2.conf
/sbin/rmmod jffs2

touch /etc/modprobe.d/hfs.conf
echo "install hfs /bin/true" > /etc/modprobe.d/hfs.conf
/sbin/rmmod hfs

touch /etc/modprobe.d/hfsplus.conf
echo "install hfsplus /bin/true" > /etc/modprobe.d/hfsplus.conf
/sbin/rmmod hfsplus

touch /etc/modprobe.d/squashfs.conf
echo "install squashfs /bin/true" > /etc/modprobe.d/squashfs.conf
/sbin/rmmod squashfs

touch /etc/modprobe.d/udf.conf
echo "install udf /bin/true" > /etc/modprobe.d/udf.conf
/sbin/rmmod udf
