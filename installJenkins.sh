#! /bin/bash

#  sudo not needed cuz terraform executes this script as root

#install java
yum install java-11-amazon-corretto-headless -y

# download & install jenkins
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y

#start jenkins
systemctl start jenkins

# enable jenkins
systemctl enable jenkins
#yum install git -y

#make sure jenkins comes up when reboot
chkconfig jenkins on