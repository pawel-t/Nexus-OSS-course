#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

#common variables
NEXUS_VERSION=3.73.0-12
OpenJDK_VERSION=11
NEXUS_HOME=/opt/nexus
NEXUS_DOWNLOAD_URL="https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-java${OpenJDK_VERSION}-unix.tar.gz"



# Install OpenJDK 11
apt update
apt-cache search openjdk # To check the available versions
apt install -y "openjdk-${OpenJDK_VERSION}-jre"
java -version


# Prepare directories
mkdir -p /opt/nexus
cd "${NEXUS_HOME}"


# Download and unzip Nexus Repository Manager
wget -O "${NEXUS_HOME}/nexus-${NEXUS_VERSION}-unix.tar.gz" "${NEXUS_DOWNLOAD_URL}"
tar -zxvf "${NEXUS_HOME}/nexus-${NEXUS_VERSION}-unix.tar.gz"


# Create a symbolic link
ln -s "${NEXUS_HOME}/nexus-${NEXUS_VERSION}" "${NEXUS_HOME}/latest"


# Create a user for Nexus
groupadd -g 900 nexus
useradd -u 900 -g 900 -s /bin/bash -M -N -r -d /opt/nexus nexus


# Change the owner of the Nexus directory
chown -R nexus:nexus "${NEXUS_HOME}"


# Create a systemd service file
cp nexus.service /etc/systemd/system/nexus.service

# Reload the systemd service
systemctl daemon-reload

# Start and enable the Nexus service
systemctl start nexus
systemctl enable nexus

# Check the status of the Nexus service
systemctl status nexus
