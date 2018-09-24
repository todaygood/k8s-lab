#

KEY_PATH=/etc/pki/rpm-gpg

for i in RPM-GPG-KEY-CentOS-SIG-Cloud RPM-GPG-KEY-CentOS-SIG-Virtualization RPM-GPG-KEY-CentOS-SIG-Storage  RPM-GPG-KEY-EPEL-7 
do
rpm --import  $KEY_PATH/$i

done
