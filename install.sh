#!/bin/sh
while getopts "l:u:p:" opt; do
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
    esac
done

# Variables
imKitName=agent.installer.linux.gtk.x86_64_1.9.0.20190715_0328.zip
repositoryUrl=http://www.ibm.com/software/repositorymanager/com.ibm.websphere.ND.v90
wasNDTraditional=com.ibm.websphere.ND.v90_9.0.5001.20190828_0616
ibmJavaSDK=com.ibm.java.jdk.v8_8.0.5040.20190808_0919

# Install IBM Installation Manager
wget -O "$imKitName" "$imKitLocation"
sudo apt install unzip
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
./IBM/WebSphere/bin/manageprofiles.sh -create -profileName AppSrv1 -templatePath ./IBM/WebSphere/profileTemplates/default
./IBM/WebSphere/profiles/AppSrv1/bin/startServer.sh server1
