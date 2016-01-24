#!/bin/bash

SPARK_PROFILE=1.6
SPARK_VERSION=1.6.0
HADOOP_PROFILE=2.6
HADOOP_VERSION=2.6.0

curl -sL "http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s /usr/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE /usr/spark \
  && rm -rf /usr/spark/examples \
  && rm /usr/spark/lib/spark-examples*.jar

git pull && git checkout -q 9308ee1
sed -i 's/--no-color/buildSkipTests --no-color/' zeppelin-web/pom.xml
mvn clean package -DskipTests \
  -Ppyspark \
  -Pspark-$SPARK_PROFILE \
  -Dspark.version=$SPARK_VERSION \
  -Phadoop-$HADOOP_PROFILE \
  -Dhadoop.version=$HADOOP_VERSION
easy_install py4j

cat > $ZEPPELIN_HOME/conf/zeppelin-env.sh <<CONF
# See conf/zeppelin-env.sh.template for additional
# Zeppelin environment variables to set from here.

export SPARK_HOME=/usr/spark
export ZEPPELIN_MEM="-Xmx1024m"
CONF
