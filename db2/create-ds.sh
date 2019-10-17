#!/bin/sh
# Parameters
adminUserName=$1 #User id for admimistrating WebSphere
adminPassword=$2 #Password for administrating WebSphere
wasServerName=$3 #WAS ND server name
dbUserName=$4 #Database user name of IBM DB2 Server
dbUserPwd=$5 #Database user password of IBM DB2 Server
dbName=$6 #Database name of IBM DB2 Server
dbServerName=$7 #Host name/IP address of IBM DB2 Server
dbServerPortName=$8 #Server port number of IBM DB2 Server
wsAdminPath=$9 #Path of wsadmin.sh

# Variables
createDSFileUri=https://raw.githubusercontent.com/majguo/arm-ubuntu-was-nd/feature/1611928-configure-jdbc-provider-and-data-source-for-was/db2/create-ds.py
createDSFileName=create-ds.py
jdbcDriverPath=./db2/java

# Copy jdbc drivers
mkdir -p "$jdbcDriverPath"
find . -name "db2jcc*.jar" | xargs -I{} cp {} "$jdbcDriverPath"
jdbcDriverPath=$(realpath "$jdbcDriverPath")

# Get jython file template & replace placeholder strings with user-input parameters
wget -O "$createDSFileName" "$createDSFileUri"
sed -i "s/\${WAS_SERVER_NAME}/${wasServerName}/g" "$createDSFileName"
sed -i "s#\${DB2UNIVERSAL_JDBC_DRIVER_PATH}#${jdbcDriverPath}#g" "$createDSFileName"
sed -i "s/\${DB2_DATABASE_USER_NAME}/${dbUserName}/g" "$createDSFileName"
sed -i "s/\${DB2_DATABASE_USER_PASSWORD}/${dbUserPwd}/g" "$createDSFileName"
sed -i "s/\${DB2_DATABASE_NAME}/${dbName}/g" "$createDSFileName"
sed -i "s/\${DB2_SERVER_NAME}/${dbServerName}/g" "$createDSFileName"
sed -i "s/\${PORT_NUMBER}/${dbServerPortName}/g" "$createDSFileName"

# Create JDBC provider and data source using jython file
"$wsAdminPath"/wsadmin.sh -lang jython -username "$adminUserName" -password "$adminPassword" -f "$createDSFileName"
