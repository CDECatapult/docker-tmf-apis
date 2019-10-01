FROM ubuntu:16.04

RUN apt-get update; \
    apt-get install -y --fix-missing python2.7 net-tools python-pip git wget unzip maven mysql-client openjdk-8-jdk; \
    wget http://download.java.net/glassfish/4.1/release/glassfish-4.1.zip; \
    unzip glassfish-4.1.zip; \
    pip install sh; \
    wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz; \
    tar -xvf mysql-connector-java-5.1.39.tar.gz; \
    cp ./mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar glassfish4/glassfish/domains/domain1/lib; \
    mkdir /apis; \
    mkdir -p /etc/default/tmf/

WORKDIR /apis

RUN mkdir wars

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSPRODUCTORDERING.git

WORKDIR DSPRODUCTORDERING

RUN git checkout 0a34fdce055a249740de89294c2b9f760b02d2f6; \
    sed -i 's/jdbc\/sample/jdbc\/podbv2/g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    if [ -f "./src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./src/main/java/org/tmf/dsmapi/settings.properties ./src/main/resources/settings.properties; fi; \
    grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
    mvn install; \
    mv ./target/DSProductOrdering.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSPRODUCTINVENTORY.git

WORKDIR DSPRODUCTINVENTORY

RUN git checkout 5c94bd874d08f84b9a58a890ebe0580d824364dc; \
sed -i 's/jdbc\/sample/jdbc\/pidbv2/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSProductInventory.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSPARTYMANAGEMENT.git

WORKDIR DSPARTYMANAGEMENT

RUN git checkout 1efd63fed97727bde09b4b44c312ff0692d1c082; \
sed -i 's/jdbc\/sample/jdbc\/partydb/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSPartyManagement.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSBILLINGMANAGEMENT.git

WORKDIR DSBILLINGMANAGEMENT

RUN git checkout 837279cd99a682ea98f96de9aeace48bdfa2dba6; \
sed -i 's/jdbc\/sample/jdbc\/bmdbv2/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSBillingManagement.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSCUSTOMER.git

WORKDIR DSCUSTOMER

RUN git checkout 68e82a8f989a5a53022ba65e7ccb592bf1f276a4; \
sed -i 's/jdbc\/sample/jdbc\/customerdbv2/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSCustomerManagement.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSUSAGEMANAGEMENT.git

WORKDIR DSUSAGEMANAGEMENT

RUN git checkout 4e4fc01c6f8a6e0a755e3a47cbc31fd763a9c934; \
    sed -i 's/jdbc\/sample/jdbc\/usagedbv2/g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
    grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
    mvn install; \
    mv ./target/DSUsageManagement.war ../wars/


WORKDIR /apis

RUN mkdir wars-ext
VOLUME ["/apis/wars-ext", "/etc/default/tmf/"]

COPY ./entrypoint.sh /
COPY ./apis-entrypoint.py /

EXPOSE 4848
EXPOSE 8080

# ENV PATH=$PATH:/glassfish4/glassfish/bin
# RUN asadmin start-domain

ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT [ "/apis-entrypoint.py" ]
