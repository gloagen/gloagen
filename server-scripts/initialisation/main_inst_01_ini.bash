#!/bin/sh 
HOSTNAME=clds01.glogn.net

JAVA_PROFILE_FILE=/etc/profile.d/java.sh

HOSTNAME_FILE=/etc/HOSTNAME

JAVA_GZ_FILE=jdk-8u92-linux-x64.tar.gz
JAVA_DOWNLOAD=http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.tar.gz

JAVA_JVM_DIRECTORY=/usr/jvm
JAVA_DIR_NAME=jdk1.8.0_92

MAVEN_HOME=/usr/lib/maven
MAVEN_DIR=apache-maven-3.3.9
MAVEN_GZ_FILE=$MAVEN_DIR-bin.tar.gz 
MAVEN_PROFILE_FILE=/etc/profile.d/maven.sh

#MOUNT INFO
MOUNT_TARGET_DNS=ir1b.nfs.glogn.net
MOUNT_DIR=/efs
MOUNT_APP_DIR=$MOUNT_DIR/inst/01

#zypper up
echo $HOSTNAME > $HOSTNAME_FILE
hostname $HOSTNAME 

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

setup_devices() {

echo "called device setup with args => $1 ~ $2 ~ $3"

	if [ "$1" != "##" ]
		then
			cat /etc/fstab
			useradd -m -d $1 $2
			echo "$2 Home directory is: $1"
	else 
		echo "could not complete device setup... for $2"
	fi	
}


#uncoment this lie to install java and maven
wget_install_java 
wget_install_mvn

apt-get install git

#creating mount point and standard users
mkdir $MOUNT_DIR
mount -t nfs4 -o vers=4.1 ir1b.nfs.glogn.net:/  $MOUNT_DIR
echo "$MOUNT_TARGET_DNS:/ /mnt$MOUNT_DIR nfs defaults,vers=4.1 0 0" >> /etc/fstab
#MOUNT_FILE=/etc/fstab
mount -a

JIRA_DIR=$MOUNT_APP_DIR/jira	
setup_devices $JIRA_DIR jira

#bitbucket config
BITBUCKET_DIR=$MOUNT_APP_DIR/bitbucket
setup_devices $BITBUCKET_DIR bitbucket
		
#bamboo config
BAMBOO_DIR=$MOUNT_APP_DIR/bamboo
setup_devices $BAMBOO_DIR bamboo

#confluence configs
CONFLUENCE_DIR=$MOUNT_APP_DIR/confluence
setup_devices $CONFLUENCE_DIR confluence

#artifactory configs
ARTIFACTORY_DIR=$MOUNT_APP_DIR/artifactory
setup_devices $ARTIFACTORY_DIR artifactory

#postgresql configs
POSTGRESQL_DIR=$MOUNT_APP_DIR/postgres
setup_devices $POSTGRESQL_DIR postgresql

#wildfly configs
WILDFLY_DEVICE=xvdl
WILDFLY_DIR=$MOUNT_APP_DIR/jboss/wildfly
setup_devices $WILDFLY_DIR wildfly

#copy pg95.env
cp /efs/inst/01/postgres/pg95/pg95.env /etc/profile.d/pg95.sh
chmod u+x /etc/profile.d/pg95.sh
sh /etc/profile.d/pg95.sh

echo "mounting devices"
mount -a
echo "completed all configurations"
df -H
