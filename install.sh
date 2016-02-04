#!/bin/bash

git pull

mvn clean package -DskipTests -Ppyspark
easy_install py4j

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

export ZEPPELIN_MEM="-Xmx1024m"
CONF
