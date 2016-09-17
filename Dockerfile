FROM gettyimages/spark:2.0.0-hadoop-2.7

# SciPy
RUN set -ex \
 && buildDeps=' \
    libpython3-dev \
    build-essential \
    pkg-config \
    gfortran \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends \
    $buildDeps \
    ca-certificates \
    wget \
    liblapack-dev \
    libopenblas-dev \
 && packages=' \
    numpy \
    pandasql \
    scipy \
 ' \
 && pip3 install $packages \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Zeppelin
ENV ZEPPELIN_PORT 8080
ENV ZEPPELIN_HOME /usr/zeppelin
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_COMMIT 383402dc69a9ecc8a34cd0f9ebaf4732c51d36d7
RUN set -ex \
 && buildDeps=' \
    git \
    bzip2 \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libcairo-dev \
    libssh2-1-dev \
 ' \
 && binaries=' \
    r-base \
    r-base-dev \
 ' \
 && echo "deb http://mirrors.cicku.me/CRAN/bin/linux/debian jessie-cran3/" >> /etc/apt/sources.list \
 && apt-get update && apt-get install -y --force-yes --no-install-recommends $buildDeps $binaries \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
   | gunzip \
   | tar x -C /tmp/ \
 && ln -s $JAVA_HOME/bin/java /usr/bin/java \
 && R CMD javareconf \
 && R -e "install.packages('devtools', repos = 'http://cran.us.r-project.org', dependencies=T)" \
 && R -e "install.packages('knitr', repos = 'http://cran.us.r-project.org', dependencies=T)" \
 && R -e "install.packages('ggplot2', repos = 'http://cran.us.r-project.org', dependencies=T)" \
 && R -e "install.packages(c('devtools','mplot', 'googleVis'), repos = 'http://cran.us.r-project.org', dependencies=T);" \
 && git clone https://github.com/apache/zeppelin.git /usr/src/zeppelin \
 && cd /usr/src/zeppelin \
 && git checkout -q $ZEPPELIN_COMMIT \
 && dev/change_scala_version.sh "2.11" \
 && sed -i 's/--no-color/buildSkipTests --no-color/' zeppelin-web/pom.xml \
 && MAVEN_OPTS="-Xms512m -Xmx1024m" /tmp/apache-maven-3.3.9/bin/mvn --batch-mode package -DskipTests -Pscala-2.11 -Pr -Psparkr -Pbuild-distr \
  -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,hbase,postgresql,jdbc,python,elasticsearch,zeppelin-web,zeppelin-server,zeppelin-distribution' \
 && tar xvf /usr/src/zeppelin/zeppelin-distribution/target/zeppelin*.tar.gz -C /usr/ \
 && mv /usr/zeppelin* $ZEPPELIN_HOME \
 && mkdir -p $ZEPPELIN_HOME/logs \
 && mkdir -p $ZEPPELIN_HOME/run \
 && rm -rf $ZEPPELIN_NOTEBOOK_DIR/2BWJFTXKJ \
 && apt-get purge -y --auto-remove $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/src/ \
 && rm -rf /root/.m2 \
 && rm -rf /root/.npm \
 && rm -rf /tmp/*

ADD about.json $ZEPPELIN_NOTEBOOK_DIR/2BTRWA9EV/note.json
WORKDIR $ZEPPELIN_HOME
CMD ["bin/zeppelin.sh"]
