#!/bin/sh 

JAVA_PROFILE_FILE=/etc/profile.d/java.sh

JAVA_GZ_FILE=jre-8u112-linux-x64.tar.gz
JAVA_DOWNLOAD=http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jre-8u112-linux-x64.tar.gz
JAVA_JVM_DIRECTORY=/usr/jvm
JAVA_DIR_NAME=jre1.8.0_112


apt-get update


echo "Initialising java ..."
mkdir -p $JAVA_JVM_DIRECTORY	

wget -P $JAVA_JVM_DIRECTORY --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_DOWNLOAD

tar -zxvf $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE -C $JAVA_JVM_DIRECTORY
echo "deleting file $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE"
rm -rf $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE 

touch $JAVA_PROFILE_FILE
echo "export JAVA_HOME=$JAVA_JVM_DIRECTORY/$JAVA_DIR_NAME" > $JAVA_PROFILE_FILE
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $JAVA_PROFILE_FILE


apt-get install -y git
