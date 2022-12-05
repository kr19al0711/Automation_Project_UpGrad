#!/bin/bash

echo "Running script from $(pwd)"

tempdir="/tmp"
s3bucket="upgrad-kripal"
name="Kripal_Parsekar"
invhtml="/var/www/html/inventory.html"
cronfile="/etc/cron.d/automation"

#Updating Package Details
sudo apt update -y

#Installing Apache2
which apache2

if [ $? -ne 0 ]
then
        echo "Apache is not installed on the server!!"
        echo "Installing Apache2"
        sudo apt install -y apache2
else
        echo "Apache is already installed on the server"
        apache2 -v
fi

#Starting Apache2 service if not active
systemctl status apache2 | grep "Active: active"

if [ $? -ne 0 ]
then
        echo "Apache2 service is not active"
        echo "Starting Apache2 service"
        systemctl start apache2
else
        echo "Apache2 service is active"
fi

#Enabling Service at Startup
sudo systemctl enable apache2

timestamp=$(date +%d%m%Y-%H%M%S)
logfilename="$name-httpd-logs-$timestamp"

#Changing to log file directory
cd /var/log/apache2

#Creating tar file at /tmp
tar cfv "${tempdir}/${logfilename}.tar" access.log error.log other_vhosts_access.log

#Uploading to S3
aws s3 cp "${tempdir}/${logfilename}.tar" "s3://${s3bucket}/${logfilename}.tar"

#Checking if inventory.html exist
if [ -e $invhtml ]
then
        echo "inventory.html already exist"
else
        echo "inventory.html doesn't exist"
        echo "Creating inventory.html at $invhtml"
        echo "Log Type     Time Created    Type    Size<br>" > $invhtml
fi

#Logging entry in inventory
logString="Apache2-logs         $timestamp              tar             blank<br>"
echo $logString >> $invhtml


#Checking if automation cron file is present
if [ -e $cronfile ]
then
        echo "Cron file already exist"
else
        echo "Cron file doesn't exist"
        echo "Scheduling cron job to run at 11:00am everyday"
        echo "* * * * * root /root/Automation_Project_UpGrad/automation.sh" > $cronfile
fi
