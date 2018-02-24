#!/bin/sh
######################################
# Written By Jamie McParland 2/23/2018
# Version 1.0.1
# Please update the version number after making changes to this file. 
######################################
#To run this centos7-firstrun.sh script, ssh into to the software server. software.newberg.k12.or.us
#Once logged in, issue this command, changing <NEWLINUXIPADDRESS> to the ip address of the new machine you want to run the script on.
#ssh root@<NEWLINUXIPADDRESS> 'bash -s' < /software/Software-Guest/centos7/centos7-firstrun.sh
######################################
# This is a first run script for Centos 7 boxes used by the NSD. 
# It installs and setups up SSH keys for Jamie, Tony and Ken
# Sets up time zone and syncs with NTP server.
# Sets up YUM to install security updates Sunday mornings at 3am and then reboot. 
# Sets up SNMP and sets contact to Jamie and Location to DOMDF. 
# Sets up sending logs to the district syslog server. 
# Lastly, it does a full yum update to get the system upto speed and reboots the machine. 
######################################
#Do some installs: 
#/usr/bin/yum -y install firewalld
#/usr/bin/yum install nano -y;
#/usr/bin/yum install wget -y;
#/usr/bin/yum -y install yum-cron -y;
#/usr/bin/yum -y install epel-release -y;
#/usr/bin/yum -y install htop -y;
#/usr/bin/yum install ntp -y;
#/usr/bin/yum install nfs-utils nfs-utils-lib -y;
#yum install net-snmp net-snmp-libs net-snap-utils -y;
######################################
###THIS TAKES CARE OF ALL THE ADDITIONAL PACKAGE INSTALLS WE WANT.
/usr/bin/yum install epel-release wget firewalld nano net-snmp net-snmp-libs net-snap-utils rsyslog nfs-utils nfs-utils-lib ntp htop yum-cron -y;
######################################
## Get SSH setup:
/usr/bin/mkdir -p /root/.ssh;
/usr/bin/wget -O /root/.ssh/authorized_keys http://software.newberg.k12.or.us/centos7/id_rsa.pub;
/usr/bin/chmod 700 /root/.ssh;
/usr/bin/chmod -Rf 644 /root/.ssh/authorized_keys;
######################################
# Set up time. 
/usr/bin/timedatectl set-timezone America/Los_Angeles;
/usr/sbin/chkconfig ntpd on;
/usr/sbin/service ntpd start;
######################################
# Setup system security updates:
/usr/bin/crontab -l | { cat; echo "5 3 * * Sun /sbin/shutdown -r now #Reboots the system sunday nights at 3am"; } | crontab -
/usr/bin/rm /etc/yum/yum-cron.conf;
/usr/bin/wget -O /etc/yum/yum-cron.conf http://software.newberg.k12.or.us/centos7/yum-cron.conf;
/usr/bin/chmod -Rf 644 /etc/yum/yum-cron.conf;
/usr/bin/systemctl enable yum-cron;
/usr/bin/systemctl start yum-cron;
/usr/bin/systemctl status yum-cron;
######################################
# Setup snmp, write a new config and open the firewall for it.
/usr/bin/mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig;
/usr/bin/echo -e "rocommunity  public \nsys location  "DO MDF"\nsyscontact  mcparlandj@newberg.k12.or.us\n" >> /etc/snmp/snmpd.conf
/usr/bin/systemctl start snmpd.service;
/usr/bin/systemctl enable snmpd.service;
/usr/bin/firewall-cmd --zone=public --permanent --add-port=161/udp
/usr/bin/firewall-cmd --zone=public --permanent --add-port=162/udp
/usr/bin/firewall-cmd --reload
######################################
#SEND DATA THE RSYSLOG
/usr/bin/rm /etc/rsyslog.conf;
/usr/bin/wget -O /etc/rsyslog.conf http://software.newberg.k12.or.us/centos7/rsyslog.conf;
/usr/bin/chmod -Rf 644 /etc/rsyslog.conf;
/usr/sbin/service rsyslog restart;
/usr/bin/systemctl restart rsyslog.service;
######################################
# Finally update all the damn packages on the system and reboot!
/usr/bin/yum -y update
/usr/sbin/reboot
######################################
