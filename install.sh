#!/bin/bash

SPARK_PROFILE=1.5
SPARK_VERSION=1.5.2
HADOOP_PROFILE=2.4
HADOOP_VERSION=2.4.0

curl -sL --retry 3 \
  "http://mirrors.ibiblio.org/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz" \
  | gunzip \
  | tar x -C /usr/ \
  && ln -s /usr/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE /usr/spark \
  && rm -rf /usr/spark/examples \
  && rm /usr/spark/lib/spark-examples*.jar

git pull

sed -i 's/--no-color/buildSkipTests --no-color/' zeppelin-web/pom.xml
mvn clean package -DskipTests \
  -Pspark-$SPARK_PROFILE \
  -Dspark.version=$SPARK_VERSION \
  -Phadoop-$HADOOP_PROFILE \
  -Dhadoop.version=$HADOOP_VERSION

cat > $ZEPPELIN_HOME/conf/zeppelin-env.sh <<CONF
# There are several ways to configure Zeppelin
# 1. pass individual --environment variables during docker run
# 2. assign a volume and change the conf directory i.e.,
#    -e "ZEPPELIN_CONF_DIR=/zeppelin-conf" --volumes ./conf:/zeppelin-conf
# 3. when customizing the Dockerfile, add ENV instructions
# 4. write variables to zeppelin-env.sh during install.sh, as
#    we're doing here.
#
# See conf/zeppelin-env.sh.template for additional
# Zeppelin environment variables to set from here.
#

export SPARK_HOME=/usr/spark
export ZEPPELIN_MEM="-Xmx1024m"
CONF
