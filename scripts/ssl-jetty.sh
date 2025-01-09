#!/bin/bash

# Stop script on error
set -e

# Define the variables
NEXUS_KEYSTORE_PASS="Nexus123"
NEXUS_DOMAIN="yourdomain.com"
NEXUS_DIR="/opt/nexus"

cd ${NEXUS_DIR}/certs

# Generate the keystore
openssl pkcs12 -export -inkey priv.key -in fullchain.cer -out nexus-keystore.p12 -name ${NEXUS_DOMAIN} -passout pass:${NEXUS_KEYSTORE_PASS}

# Import the keystore
keytool -importkeystore -srckeystore nexus-keystore.p12 -srcstoretype PKCS12 -destkeystore keystore.jks -deststoretype pkcs12 -srcstorepass ${NEXUS_KEYSTORE_PASS} -storepass ${NEXUS_KEYSTORE_PASS} -keypass ${NEXUS_KEYSTORE_PASS}

# Backup original config
cp ${NEXUS_DIR}/sonatype-work/nexus3/etc/nexus.properties{,.bak}

# Update nexus.properties
echo "application-port-ssl=8443
nexus-args=\${jetty.etc}/jetty.xml,\${jetty.etc}/jetty-http.xml,\${jetty.etc}/jetty-https.xml,\${jetty.etc}/jetty-requestlog.xml
ssl.etc=\${karaf.data}/etc/ssl" > ${NEXUS_DIR}/sonatype-work/nexus3/etc/nexus.properties

# Create SSL directory and copy keystore
mkdir -p ${NEXUS_DIR}/sonatype-work/nexus3/etc/ssl
cp ${NEXUS_DIR}/certs/keystore.jks ${NEXUS_DIR}/sonatype-work/nexus3/etc/ssl/keystore.jks

# Update passwords in configuration files
sed -i "s/<Set name=\"KeyStorePassword\">[^<]*<\/Set>/<Set name=\"KeyStorePassword\">${NEXUS_KEYSTORE_PASS}<\/Set>/g" ${NEXUS_DIR}/latest/etc/jetty/jetty-https.xml
sed -i "s/<Set name=\"KeyManagerPassword\">[^<]*<\/Set>/<Set name=\"KeyManagerPassword\">${NEXUS_KEYSTORE_PASS}<\/Set>/g" ${NEXUS_DIR}/latest/etc/jetty/jetty-https.xml
sed -i "s/<Set name=\"TrustStorePassword\">[^<]*<\/Set>/<Set name=\"TrustStorePassword\">${NEXUS_KEYSTORE_PASS}<\/Set>/g" ${NEXUS_DIR}/latest/etc/jetty/jetty-https.xml


systemctl restart nexus
