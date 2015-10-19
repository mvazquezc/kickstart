#version=RHEL6
# System authorization information
auth --enableshadow --passalgo=sha512

# Use CDROM installation media
#cdrom
# Run the Setup Agent on first boot
firstboot --disable
%include /tmp/initdisk
# Keyboard layouts
keyboard es
# System language
lang en_US.UTF-8

# Network information
network --hostname=localhost.localdomain

# Root password
rootpw --iscrypted $6$j3Rs00JUdeMdmHVK$uK8.AIsjE6elZI.RF9BjzX1rfgx64SNvxECVOj6drglmfiZxb41rL9Avmec.dZpGtFsb9OF64qguF.Tcvul0.0
# System timezone
timezone --utc Europe/Madrid
# System bootloader configuration
%include /tmp/bootloader
# Partition clearing information
zerombr
clearpart --all --initlabel 
# Disk partitioning information
%include /tmp/partboot
%include /tmp/partlvm
volgroup volgroup --pesize=4096 pv.01
%include /tmp/swappart
logvol /tmp --fstype="ext4" --size=1 --percent=5 --grow --name=lv_tmp --vgname=volgroup
logvol /var/log/audit --fstype="ext4" --size=1 --percent=2 --grow --name=lv_audit --vgname=volgroup
logvol /home --fstype="ext4" --size=1 --percent=5 --grow --name=lv_home --vgname=volgroup
logvol /opt --fstype="ext4" --size=1 --percent=15 --grow --name=lv_opt --vgname=volgroup
logvol / --fstype="ext4" --size=1 --percent=20 --grow --name=lv_root --vgname=volgroup
logvol /var/log --fstype="ext4" --size=1 --percent=15 --grow --name=lv_log --vgname=volgroup
logvol /var --fstype="ext4" --size=1 --percent=15 --grow --name=lv_var --vgname=volgroup

%packages --nobase
@core
%end

%pre
#!/bin/bash
memory=`grep MemTotal /proc/meminfo | awk '{print $2}'`
ram=`expr $memory / 1024`
if [ $ram -gt 4096 ];then
ram=4096
fi
echo "logvol swap --fstype=swap --size=$ram --name=lv_swap --vgname=volgroup" > /tmp/swappart
if [ -e /dev/sda ];then
disk=sda
elif [ -e /dev/vda ];then
disk=vda
else
disk=hda
fi
echo "ignoredisk --only-use=$disk" > /tmp/initdisk
echo "bootloader --location=mbr --driveorder=$disk" > /tmp/bootloader
echo "part /boot --fstype=ext2 --ondisk=$disk --size=500" > /tmp/partboot
echo "part pv.01 --size=1 --grow --ondisk=$disk" > /tmp/partlvm
%end
