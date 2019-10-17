#!/bin/sh
# Parameters
adminUserName=$1 #User id for admimistrating WebSphere
adminPassword=$2 #Password for administrating WebSphere
wasProfileName=$3 #WAS ND profile name
wasServerName=$4 #WAS ND server name
dbUserName=$5 #Database user name of IBM DB2 Server
dbUserPwd=$6 #Database user password of IBM DB2 Server
dbName=$7 #Database name of IBM DB2 Server
dbServerName=$8 #Host name/IP address of IBM DB2 Server
dbServerPortName=$9 #Server port number of IBM DB2 Server
wasRootPath=$10 #Root path of WebSphere

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
"$wasRootPath"/bin/wsadmin.sh -lang jython -username "$adminUserName" -password "$adminPassword" -f "$createDSFileName"

# Restart server
"$wasRootPath"/profiles/"$wasProfileName"/bin/stopServer.sh "$wasServerName" -username "$adminUserName" -password "$adminPassword"
"$wasRootPath"/profiles/"$wasProfileName"/bin/startServer.sh "$wasServerName"
