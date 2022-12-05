#!/bin/bash

echo "Running script from $(pwd)"

tempdir="/tmp"
s3bucket="upgrad-kripal"
name="Kripal_Parsekar"

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
