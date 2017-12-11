#!/bin/sh

JAVA_DOWNLOAD=http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
JAVA_PROFILE_FILE=/etc/profile.d/java.sh
JAVA_GZ_FILE=jdk-8u131-linux-x64.tar.gz
JAVA_JVM_DIRECTORY=/usr/jvm
JAVA_DIR_NAME=jdk1.8.131

wget_install_java(){
	echo "Initialising java ..."
	mkdir -p $JAVA_JVM_DIRECTORY

	wget -P $JAVA_JVM_DIRECTORY --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_DOWNLOAD

	tar -zxvf $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE -C $JAVA_JVM_DIRECTORY
	echo "deleting file $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE"
	rm -rf $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE

	echo "deleting file /etc/profile.d/java.sh"
	rm -rf $JAVA_PROFILE_FILE

	touch $JAVA_PROFILE_FILE
	echo "export JAVA_HOME=$JAVA_JVM_DIRECTORY/$JAVA_DIR_NAME" > $JAVA_PROFILE_FILE
	#echo			 >> $JAVA_PROFILE_FILE
	echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $JAVA_PROFILE_FILE
}

wget_install_java