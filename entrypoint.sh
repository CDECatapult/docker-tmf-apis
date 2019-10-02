#!/usr/bin/env bash
set -e

echo "Deploying API ${MYSQL_DATABASE}"
python /deploy-api.py

# Make the war files available
cp /apis/wars/* /apis/wars-ext/

# --verbose runs glassfish in the foreground
/glassfish4/glassfish/bin/asadmin start-domain --verbose
