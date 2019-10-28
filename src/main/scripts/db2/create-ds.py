# Reference: https://raw.githubusercontent.com/keensoft/was-db2-docker/master/was/assets/create-datasource.jython

# Get WAS server id as the parent ID for creating JDBC provider
server = AdminConfig.getid('/Server:${WAS_SERVER_NAME}/')

# JDBC Provider
n1 = ['name', 'DB2JDBCProvider']
implCN = ['implementationClassName', 'com.ibm.db2.jcc.DB2XADataSource']
cls = ['classpath', '${DB2UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc.jar;${DB2UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc_license_cu.jar;${DB2UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc_license_cisuz.jar']
provider = ['providerType', 'DB2 Universal JDBC Driver Provider (XA)']
xa = ['xa', 'true']
jdbcAttrs = [n1,  implCN, cls, provider, xa]
jdbCProvider = AdminConfig.create('JDBCProvider', server, jdbcAttrs)

# JASS Auth entry
userAlias = 'wasnd/db2'
alias = ['alias', userAlias]
userid = ['userId', '${DB2_DATABASE_USER_NAME}']
password = ['password', '${DB2_DATABASE_USER_PASSWORD}']
jaasAttrs = [alias, userid, password]
security = AdminConfig.getid('/Security:/')
j2cUser = AdminConfig.create('JAASAuthData', security, jaasAttrs)

# Data Source
newjdbc = AdminConfig.getid('/JDBCProvider:DB2JDBCProvider/')
name = ['name', 'DB2DataSource']
jndi = ['jndiName', 'DB2DataSource']
auth = ['authDataAlias' , userAlias]
authMechanism = ['authMechanismPreference' , 'BASIC_PASSWORD']
helper = ['datasourceHelperClassname', 'com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper']
dsAttrs = [name, jndi, auth, authMechanism, helper]
newds = AdminConfig.create('DataSource', newjdbc, dsAttrs)

# Data Source properties
propSet = AdminConfig.create('J2EEResourcePropertySet', newds, [])
AdminConfig.create('J2EEResourceProperty', propSet, [["name", "driverType"], ["value", "4"]])
AdminConfig.create('J2EEResourceProperty', propSet, [["name", "databaseName"], ["value", "${DB2_DATABASE_NAME}"]])
AdminConfig.create('J2EEResourceProperty', propSet, [["name", "serverName"], ["value", "${DB2_SERVER_NAME}"]])
AdminConfig.create('J2EEResourceProperty', propSet, [["name", "portNumber"], ["value", "${PORT_NUMBER}"]])

# Save configuratoin changes
AdminConfig.save()
