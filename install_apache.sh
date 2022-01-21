#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
yum update -y
yum install -y mod_ssl
sudo /etc/pki/tls/certs/make-dummy-cert localhost.crt
sed 's/SSLCertificateKeyFile/# SSLCertificateKeyFile/g' /etc/httpd/conf.d/ssl.conf
systemctl restart httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
sudo amazon-linux-extras install epel -y
sudo yum install stress -y
sudo stress --cpu 8 --vm-bytes $(awk '/MemAvailable/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1