#!/bin/bash

echo "KERNEL UPDATE"

cat << EOF > /home/centos/kernel-update.sh 

sudo  -i

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

yum --disablerepo='*' --enablerepo='elrepo-kernel' list available

yum --enablerepo=elrepo-kernel -y install kernel-ml

sed -i '/GRUB_DEFAULT/c\GRUB_DEFAULT=0'  /etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg

EOF
