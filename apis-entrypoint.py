#!/usr/bin/env python
# Credits of this code to @Rock_Neurotiko
from sh import asadmin, cd, sed
from os import getenv
import time
import sys

# DBUSER = "root"
# DBPWD = getenv("MYSQL_ROOT_PASSWORD", "toor")
# DBHOST = getenv("MYSQL_HOST", "localhost")
# DBPORT = "3306"

API_NAME = sys.argv[1]
DBUSER = getenv("MYSQL_USER")
DBPWD = getenv("MYSQL_PASSWORD")
DBHOST = getenv("MYSQL_HOST")
DBPORT = getenv("MYSQL_PORT", "3306")

APIS = {
    "DSPRODUCTORDERING": {
        "war": "DSProductOrdering.war",
        "root": "DSProductOrdering",
        "resourcename": "jdbc/podbv2"
    },
    "DSPRODUCTINVENTORY": {
        "war": "DSProductInventory.war",
        "root": "DSProductInventory",
        "resourcename": "jdbc/pidbv2"
    },
    "DSPARTYMANAGEMENT": {
        "war": "DSPartyManagement.war",
        "root": "DSPartyManagement",
        "resourcename": "jdbc/partydb"
    },
    "DSBILLINGMANAGEMENT": {
        "war": "DSBillingManagement.war",
        "root": "DSBillingManagement",
        "resourcename": "jdbc/bmdbv2"
    },
    "DSCUSTOMER": {
        "war": "DSCustomerManagement.war",
        "root": "DSCustomerManagement",
        "resourcename": "jdbc/customerdbv2"
    },
    "DSUSAGEMANAGEMENT": {
        "war": "DSUsageManagement.war",
        "root": "DSUsageManagement",
        "resourcename": "jdbc/usagedbv2"
    }
}


def pool(name, user, pwd, url):
    if name not in asadmin("list-jdbc-connection-pools").splitlines():
        try:
            asadmin("create-jdbc-connection-pool",
                    "--restype",
                    "java.sql.Driver",
                    "--driverclassname",
                    "com.mysql.jdbc.Driver",
                    "--property",
                    "user={}:password={}:URL={}".format(
                        user, pwd, url.replace(":", "\:")),
                    name)
            print('JDBC connection pool {} created'.format(name))
        except Exception as e:
            print('JDBC connection pool {} creation failed'.format(name))
            print(e)
            exit(1)


# asadmin create-jdbc-resource --connectionpoolid <poolname> <jndiname>
def resource(name, pool):
    if name not in asadmin("list-jdbc-resources").splitlines():
        try:
            asadmin("create-jdbc-resource", "--connectionpoolid", pool, name)
            print('JDBC resource {} created'.format(name))
        except Exception as e:
            print('JDBC resource {} creation failed'.format(name))
            print(e)
            exit(1)


def generate_mysql_url(db):
    return "jdbc:mysql://{}:{}/{}".format(DBHOST, DBPORT, db)


start_time = time.time()

asadmin("start-domain")

api = APIS.get(API_NAME)

pool(API_NAME, DBUSER, DBPWD, generate_mysql_url(API_NAME))
resource(api.get("resourcename"), API_NAME)

cd("wars")
try:
    asadmin("deploy", "--force", "true", "--contextroot",
            api.get('root'), "--name", api.get('root'), api.get('war'))
    print('API {} deployed'.format(API_NAME))
    # Attempt to dial down logging
    sed("-i", 
        "s/java.util.logging.ConsoleHandler.level=FINEST/java.util.logging.ConsoleHandler.level=WARNING/g",
        "/glassfish4/glassfish/domains/domain1/config/logging.properties")
    
except Exception as e:
    print('API {} could not be deployed'.format(API_NAME))
    print(e)
    exit(1)

elapsed_time = time.time() - start_time
print(elapsed_time)
cd("..")

asadmin("stop-domain")
