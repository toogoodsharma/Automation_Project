#!/bin/bash
s3bucket="upgrad-siddharth"
name="siddharth"
sudo apt update -y

if [[ apache2 != $(dpkg --get-selections apache2 | awk '{print $1}') ]];
then
	sudo apt install apache2 -y
fi

running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running != ${running} ]]; 
then
	sudo systemctl start apache2
fi
enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]];
then
	sudo systemctl enable apache2
fi

echo ">Checking if aws cli is installed"
type -p apache2 > /dev/null 2>&1 || {
        echo ">[aws] NOT found!, installing it ..."
}
sleep 2
apt install awscli > /dev/null 2>&1
aws_version=$(aws --version)
echo -e ">[aws] version: $aws_version\n"

timestamp=$(date '+%d%m%Y-%H%M%S')
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log
if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]];
then
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3bucket}/${name}-httpd-logs-${timestamp}.tar
fi

