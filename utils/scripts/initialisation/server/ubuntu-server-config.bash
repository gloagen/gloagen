#!/bin/sh 


JAVA_PROFILE_FILE=/etc/profile.d/java.sh


JAVA_GZ_FILE=jdk-8u77-linux-x64.tar.gz
JAVA_DOWNLOAD=http://download.oracle.com/otn-pub/java/jdk/8u77-b03/jdk-8u77-linux-x64.tar.gz
JAVA_JVM_DIRECTORY=/usr/jvm
JAVA_DIR_NAME=jdk1.8.0_77

MAVEN_HOME=/usr/lib/maven
MAVEN_DIR=apache-maven-3.3.9
MAVEN_GZ_FILE=$MAVEN_DIR-bin.tar.gz 
MAVEN_PROFILE_FILE=/etc/profile.d/maven.sh

#apt-get update



wget_install_java(){
	echo "Initialising java ..."
	mkdir -p $JAVA_JVM_DIRECTORY	

	wget -P $JAVA_JVM_DIRECTORY --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_DOWNLOAD

	tar -zxvf $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE -C $JAVA_JVM_DIRECTORY
	echo "deleting file $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE"
	rm -rf $JAVA_JVM_DIRECTORY/$JAVA_GZ_FILE 

	touch $JAVA_PROFILE_FILE
	echo "export JAVA_HOME=$JAVA_JVM_DIRECTORY/$JAVA_DIR_NAME" > $JAVA_PROFILE_FILE
	#echo			 >> $JAVA_PROFILE_FILE
	echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $JAVA_PROFILE_FILE

}

wget_install_mvn(){
	wget -P $MAVEN_HOME http://mirror.catn.com/pub/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
	tar -zxvf $MAVEN_HOME/$MAVEN_GZ_FILE -C $MAVEN_HOME
	rm -f $MAVEN_HOME/$MAVEN_GZ_FILE
	
	echo "export M2_HOME=$MAVEN_HOME/$MAVEN_DIR" > $MAVEN_PROFILE_FILE
	echo "export M2=\$M2_HOME/bin" >> $MAVEN_PROFILE_FILE
	echo "export PATH=\$M2:\$PATH" >> $MAVEN_PROFILE_FILE
}



#creating mount point and standard users

setup_devices() {

echo "called device setup with args => $1 ~ $2 ~ $3"

	if [ "$1" != "##" ]
		then
			
			#deluser $3
			mkdir -p $2
			useradd -m -d $2 $3
			#usermod -a -G appusers $3
			chown $3 $2
			chgrp -R appusers $2
			
			echo "/dev/$1 $2 ext4 defaults 1 1" >> /etc/fstab
			echo "Inserted entry fstab"
			echo "effective fstab file looks like the following:"
			cat /etc/fstab
			
			echo "Completed $3 initialisation ..."
			echo "$3 Home directory is: $2"
	else 
		echo "could not complete device setup... for $1 and $2"
	fi	
}

groupadd appusers
#uncoment this lie to install java and maven
wget_install_java 
#wget_install_mvn
apt-get install -y git

#attach device, then specify deveice id here
# i.e. the device name for -> /dev/xvdf1 will be xvdf1
JIRA_DEVICE=xvdf1	
JIRA_DIR=/opt/jira	
setup_devices $JIRA_DEVICE $JIRA_DIR jira

#bitbucket config
BITBUCKET_DEVICE=xvdi1
BITBUCKET_DIR=/opt/bitbucket
setup_devices $BITBUCKET_DEVICE $BITBUCKET_DIR bitbucket
		
#bamboo config
BAMBOO_DEVICE=xvdh1
BAMBOO_DIR=/opt/bamboo
setup_devices $BAMBOO_DEVICE $BAMBOO_DIR bamboo

#confluence configs
CONFLUENCE_DEVICE=xvdj1
CONFLUENCE_DIR=/opt/confluence
setup_devices $CONFLUENCE_DEVICE $CONFLUENCE_DIR confluence

#artifactory configs
ARTIFACTORY_DEVICE=xvdk1
ARTIFACTORY_DIR=/opt/artifactory
setup_devices $ARTIFACTORY_DEVICE $ARTIFACTORY_DIR artifactory

#postgresql configs
POSTGRESQL_DEVICE=xvdg1
POSTGRESQL_DIR=/opt/database/postgresql
setup_devices $POSTGRESQL_DEVICE $POSTGRESQL_DIR postgresql

#wildfly configs
#WILDFLY_DEVICE=xvdl
#WILDFLY_DIR=/opt/wildfly
#setup_devices $WILDFLY_DEVICE $WILDFLY_DIR wildfly

#copy pg95.env
#cp /opt/database/postgresql/pg95/pg95.env /etc/profile.d/pg95.sh
#chmod ugo-x /etc/profile.d/pg95.sh
#sh /etc/profile.d/pg95.sh


echo "mounting devices"
mount -a
echo "completed all configurations"
df -H
