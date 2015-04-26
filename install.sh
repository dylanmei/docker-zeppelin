#!/bin/bash

SPARK_PROFILE=1.3
SPARK_VERSION=1.3.0
HADOOP_PROFILE=2.4
HADOOP_VERSION=2.4.0

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
# 3. set them during the build, as the example below
# 4. when customizing the Docker build, add ENV instructions
#
# See conf/zeppelin-env.sh.template for additional
# Zeppelin environment variables to set from here.

export ZEPPELIN_MEM="-Xmx1024m"
CONF
