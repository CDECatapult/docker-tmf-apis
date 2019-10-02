#!/usr/bin/env python
# Credits of this code to @Rock_Neurotiko
import os
os.environ['PATH'] = "{}:/glassfish4/glassfish/bin".format(os.environ.get("PATH"))

from sh import asadmin, cd, sed
import time
import sys

API_NAME = os.environ.get("MYSQL_DATABASE")
DBUSER = os.environ.get("MYSQL_USER")
DBPWD = os.environ.get("MYSQL_PASSWORD")
DBHOST = os.environ.get("MYSQL_HOST")
DBPORT = os.environ.get("MYSQL_PORT", "3306")

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
            print(asadmin("create-jdbc-connection-pool",
                    "--restype",
                    "java.sql.Driver",
                    "--driverclassname",
                    "com.mysql.jdbc.Driver",
                    "--property",
                    "user={}:password={}:URL={}".format(
                        user, pwd, url.replace(":", "\:")),
                    name))
            print('JDBC connection pool {} created'.format(name))
            sys.stdout.flush()
        except Exception as e:
            print('JDBC connection pool {} creation failed'.format(name))
            print(e)
            sys.stdout.flush()
            exit(1)


# asadmin create-jdbc-resource --connectionpoolid <poolname> <jndiname>
def resource(name, pool):
    if name not in asadmin("list-jdbc-resources").splitlines():
        try:
            print(asadmin("create-jdbc-resource", "--connectionpoolid", pool, name))
            print('JDBC resource {} created'.format(name))
            sys.stdout.flush()
        except Exception as e:
            print('JDBC resource {} creation failed'.format(name))
            print(e)
            sys.stdout.flush()
            exit(1)

def deploy(name, root, war):
    cd("wars")
    try:
        print(asadmin("deploy", "--force", "true", "--contextroot",
                root, "--name", root, war))
        print('API {} deployed'.format(name))
        sys.stdout.flush()
        # Attempt to dial down logging
        sed("-i", 
            "s/java.util.logging.ConsoleHandler.level=FINEST/java.util.logging.ConsoleHandler.level=WARNING/g",
            "/glassfish4/glassfish/domains/domain1/config/logging.properties")
    except Exception as e:
        print('API {} could not be deployed'.format(name))
        print(e)
        sys.stdout.flush()
        exit(1)
    cd("..")


def generate_mysql_url(db):
    return "jdbc:mysql://{}:{}/{}".format(DBHOST, DBPORT, db)


start_time = time.time()

# Glassfish server must be running in the background for the various
# JDBC and deployment tasks to run, but we want the container to run it in
# the foreground as docker's entrypoint; so we start it here and then stop
# it once setup is complete
asadmin("start-domain")

api = APIS.get(API_NAME)

pool(API_NAME, DBUSER, DBPWD, generate_mysql_url(API_NAME))
resource(api.get("resourcename"), API_NAME)
deploy(API_NAME, api.get("root"), api.get("war"))

elapsed_time = time.time() - start_time
print(elapsed_time)
sys.stdout.flush()

asadmin("stop-domain")
