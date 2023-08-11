#!bin/bash

#Udate and install java 17
dnf update
dnf install java-17 -y

#Download the binaries for SonarQube 
cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.1.69595.zip?_gl=1*184mxos*_gcl_au*MTMxNzczNDMyLjE2OTE1MDQ2MDU.*_ga*MTQ2OTQxNjMzNi4xNjkxNTA0NjA4*_ga_9JZ0GZ5TC6*MTY5MTUwNDYxMS4xLjEuMTY5MTUxMjQyMS42MC4wLjA.zip
unzip sonarqube-9.9.1.69595*

#add these logs files so that they don't get added after you chown so that they can also be owned by sonaradmin
touch sonarqube-9.9.1.69595/logs/es.log sonarqube-9.9.1.69595/logs/nohup.log sonarqube-9.9.1.69595/logs/sonar.log

# Create the user to run sonarqube because it cannot be run by root users
useradd sonaradmin
chown -R sonaradmin:sonaradmin /opt/sonarqube-9.9.1.69595
su - sonaradmin -c "/opt/sonarqube-9.9.1.69595/bin/linux-x86-64/sonar.sh start"


