#!/bin/sh

set -x

yum update --disablerepo=* --enablerepo="*microsoft*"
yum install -y nfs-utils
yum install -y rpcbind
systemctl unmask firewalld
systemctl start firewalld
systemctl start nfs-server
systemctl enable nfs-server
mkdir -p /exports/home
echo "/exports/home *(rw,sync,subtree_check,no_root_squash)" >> /etc/exports
mkfs.xfs /dev/sdb
sleep 10
mount /dev/sdb /exports/home
#chown -R nfsnobody:nfsnobody /exports/home
chmod -R 777 /exports/home
exportfs -a
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload
echo "$(sudo blkid | grep /dev/sdb | awk '{print $2}') /exports/home        xfs     defaults    0 0" >> /etc/fstab