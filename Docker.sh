#! /bin/bashbash

useradd ansibleadmin

echo "ansibleansible" | passwd --stdin ansibleadmin

echo 'ansibleansible ALL=(ALL)  NOPASSWD: ALL' | sudo tee -a /etc/sudoers

echo 'ec2-user ALL=(ALL)  NOPASSWD: ALL' | sudo tee -a /etc/sudoers

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service sshd restart

yum update -y

amazon-linux-extras install docker -y

service docker start

#add ansibleadmin user to docker group so you can execute docker commands without sudo
usermod -a -G docker ansibleadmin
