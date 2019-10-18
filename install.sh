#!/bin/sh
while getopts "l:u:p:m:c:n:t:d:i:s:" opt; do
    case $opt in
        l)
            imKitLocation=$OPTARG #SAS URI of the IBM Installation Manager install kit in Azure Storage
        ;;
        u)
            userName=$OPTARG #IBM user id for downloading artifacts from IBM web site
        ;;
        p)
            password=$OPTARG #password of IBM user id for downloading artifacts from IBM web site
        ;;
        m)
            adminUserName=$OPTARG #User id for admimistrating WebSphere Admin Console
        ;;
        c)
            adminPassword=$OPTARG #Password for administrating WebSphere Admin Console
        ;;
        n)
            db2ServerName=$OPTARG #Host name/IP address of IBM DB2 Server
        ;;
        t)
            db2ServerPortNumber=$OPTARG #Server port number of IBM DB2 Server
        ;;
        d)
            db2DBName=$OPTARG #Database name of IBM DB2 Server
        ;;
        i)
            db2DBUserName=$OPTARG #Database user name of IBM DB2 Server
        ;;
        s)
            db2DBUserPwd=$OPTARG #Database user password of IBM DB2 Server
        ;;
    esac
done

# Variables
imKitName=agent.installer.linux.gtk.x86_64_1.9.0.20190715_0328.zip
repositoryUrl=http://www.ibm.com/software/repositorymanager/com.ibm.websphere.ND.v90
wasNDTraditional=com.ibm.websphere.ND.v90_9.0.5001.20190828_0616
ibmJavaSDK=com.ibm.java.jdk.v8_8.0.5040.20190808_0919

# Update default locale C.UTF-8 as en_US.utf8 due to fix the issue that data source built-in-derby-datasource failed to create database during testing connection
update-locale LANG=en_US.utf8
. /etc/default/locale

# Install package dependencies
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update
apt-get install unzip -y

# Install IBM Installation Manager
wget -O "$imKitName" "$imKitLocation"
mkdir im_installer
unzip "$imKitName" -d im_installer
./im_installer/userinstc -log log_file -acceptLicense -installationDirectory IBM/InstallationManager

# Install IBM WebSphere Application Server Network Deployment V9 using IBM Instalation Manager
./IBM/InstallationManager/eclipse/tools/imutilsc saveCredential -secureStorageFile storage_file \
    -userName "$userName" -userPassword "$password" -url "$repositoryUrl"
mkdir -p ./IBM/WebSphere && mkdir -p ./IBM/IMShared
./IBM/InstallationManager/eclipse/tools/imcl install "$wasNDTraditional" "$ibmJavaSDK" -repositories "$repositoryUrl" \
    -installationDirectory  ./IBM/WebSphere/ -sharedResourcesDirectory ./IBM/IMShared/ \
    -secureStorageFile storage_file -acceptLicense -showProgress

# Create standalone application profile and start the server
./IBM/WebSphere/bin/manageprofiles.sh -create -profileName AppSrv1 -templatePath ./IBM/WebSphere/profileTemplates/default \
    -enableAdminSecurity true -adminUserName "$adminUserName" -adminPassword "$adminPassword"
./IBM/WebSphere/profiles/AppSrv1/bin/startServer.sh server1

# Configure JDBC provider and data soruce for IBM DB2 Server if required
if [ ! -z "$db2ServerName" ] && [ ! -z "$db2ServerPortNumber" ] && [ ! -z "$db2DBName" ] && [ ! -z "$db2DBUserName" ] && [ ! -z "$db2DBUserPwd" ]; then
    wget https://raw.githubusercontent.com/majguo/arm-ubuntu-was-nd/master/db2/create-ds.sh
    chmod u+x create-ds.sh
    ./create-ds.sh "$adminUserName" "$adminPassword" ./IBM/WebSphere server1 "$db2ServerName" "$db2ServerPortNumber" "$db2DBName" "$db2DBUserName" "$db2DBUserPwd"
    
    # Restart server
    ./IBM/WebSphere/profiles/AppSrv1/bin/stopServer.sh server1 -username "$adminUserName" -password "$adminPassword"
    ./IBM/WebSphere/profiles/AppSrv1/bin/startServer.sh server1
fi
