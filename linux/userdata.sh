#!/bin/bash

exec &> ${tfi_lx_userdata_log}

echo "FIREWALL CHECKPOINT 1"

yum -y install bc

#iptables -L -n -v
#if rpm -q iptables ; then # does system have iptables?
#  setenforce 0
#  iptables -A INPUT -p tcp -s ${tfi_cb_ip} --dport 22 -j DROP #block port 22
#  /sbin/service iptables save
#  /sbin/service iptables restart
#fi
#echo "FIREWALL CHECKPOINT 2"
#iptables -L -n -v

#sleep 20
start=`date +%s`

WATCHMAKER_INSTALL_GOES_HERE

end=`date +%s`
runtime=$((end-start))
echo "WAM install took $runtime seconds."


if rpm -q iptables ; then # does system have iptables?
  echo "FIREWALL CHECKPOINT 3"
  iptables -L -n -v
  setenforce 0
  #iptables -D INPUT 1
  iptables -I INPUT -p tcp --dport 122 -j ACCEPT #open port 122
  /sbin/service iptables save
  /sbin/service iptables restart
  echo "FIREWALL CHECKPOINT 4"
  iptables -L -n -v
fi
setenforce 0
sed -i -e '5iPort 122' /etc/ssh/sshd_config
service sshd restart

export S3_TOP_KEYFIX=$(echo ${tfi_build_id} | cut -d'_' -f 1)
export BUILD_ID=$(echo ${tfi_build_id} | cut -d'_' -f 2)"_"$(echo ${tfi_build_id} | cut -d'_' -f 3)
export OS_VERSION=$(cat /etc/redhat-release | cut -c1-3)$(cat /etc/redhat-release | sed 's/[^0-9.]*\([0-9]\.[0-9]\).*/\1/')
#export S3_KEYFIX=$(date +'%H%M%S_')$OS_VERSION
export S3_KEYFIX=$OS_VERSION

aws s3 cp ${tfi_lx_userdata_log} "s3://${tfi_s3_bucket}/$${S3_TOP_KEYFIX}/$${BUILD_ID}/$${S3_KEYFIX}/userdata.log" || true
aws s3 cp /var/log "s3://${tfi_s3_bucket}/$${S3_TOP_KEYFIX}/$${BUILD_ID}/$${S3_KEYFIX}/cloud-init/" --recursive --exclude "*" --include "cloud*log" || true
aws s3 cp /var/log/watchmaker "s3://${tfi_s3_bucket}/$${S3_TOP_KEYFIX}/$${BUILD_ID}/$${S3_KEYFIX}/watchmaker/" --recursive || true

touch /tmp/SETUP_COMPLETE_SIGNAL
