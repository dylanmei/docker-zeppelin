FROM gettyimages/spark:2.1.1-hadoop-2.7

ADD sources.list /etc/apt/sources.list

# SciPy & matplotlib
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
    matplotlib \
 ' \
 && pip3 install $packages \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# R language
ENV R_BASE_VERSION 3.4.1
## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
RUN apt-get update
RUN apt-get install -t unstable -y --no-install-recommends \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}* \
		r-base-dev=${R_BASE_VERSION}* \
		r-recommended=${R_BASE_VERSION}* \
RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
RUN
echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
RUN ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r
RUN ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r
RUN ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r
RUN ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r
RUN install.r docopt \
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
RUN rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('devtools', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('knitr', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('ggplot2', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('rJava', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('RJDBC', repos = 'http://cran.us.r-project.org')"

# Zeppelin
ENV ZEPPELIN_PORT 8080
ENV ZEPPELIN_HOME /usr/zeppelin
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_LOGS_DIR $ZEPPELIN_HOME/logs
ENV ZEPPELIN_RUN_DIR $ZEPPELIN_HOME/run
ENV ZEPPELIN_COMMIT v0.7.2
ENV MAVEN_VERION 3.5.0
ENV SCALA_VERION 2.11
RUN echo '{ "allow_root": true }' > /root/.bowerrc

RUN set -ex \
 && buildDeps=' \
    git \
    bzip2 \
    npm \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
 && curl -sL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERION/binaries/apache-maven-$MAVEN_VERION-bin.tar.gz \
   | gunzip \
   | tar x -C /tmp/
RUN git clone https://github.com/apache/zeppelin.git /usr/src/zeppelin \
 && cd /usr/src/zeppelin
RUN git checkout -q $ZEPPELIN_COMMIT
RUN dev/change_scala_version.sh $SCALA_VERION
RUN MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m"
#RUN /tmp/apache-maven-$MAVEN_VERION/bin/mvn --batch-mode package -DskipTests -Pscala-$SCALA_VERION -Pbuild-distr \
#  -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,hbase,postgresql,jdbc,python,elasticsearch,zeppelin-web,zeppelin-server,zeppelin-distribution'
# Note by kay, here, we use the same commands that creates official binary package.
RUN /tmp/apache-maven-$MAVEN_VERION/bin/mvn clean package -DskipTests -Pspark-$SPARK_VERSION -Phadoop-$HADOOP_VERSION -Pr-$R_BASE_VERSION -Pscala-$SCALA_VERION -Psparkr -Pyarn -Ppyspark
RUN tar xvf /usr/src/zeppelin/zeppelin-distribution/target/zeppelin*.tar.gz -C /usr/
RUN mv /usr/zeppelin* $ZEPPELIN_HOME
RUN mkdir -p $ZEPPELIN_LOGS_DIR
RUN mkdir -p $ZEPPELIN_RUN_DIR
RUN apt-get purge -y --auto-remove $buildDeps
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/src/zeppelin
RUN rm -rf /root/.m2
RUN rm -rf /root/.npm
RUN rm -rf /tmp/*

# note this is the reference from another image
#RUN git clone --depth 1 --branch ${ZEPPELIN_VERSION} https://github.com/apache/zeppelin.git /zeppelin && \
#    apt-get update && \
#    apt-get install -y maven && \
#    mvn  -Pscala-2.11 -Pspark-${SPARK_ZEPPELIN_VERSION} -Phadoop-${MAJOR_HADOOP_VERSION} -Psparkr -Pyarn -Ppyspark -DskipTests -Pvendor-repo clean package && \
#    apt-get install -y python-matplotlib && \
#    echo "tail -F /zeppelin/logs/*" >> bin/zeppelin-daemon.sh && \
#    mkdir ~/.config/matplotlib && \
#    echo "backend : Agg" >> ~/.config/matplotlib/matplotlibrc

RUN ln -s /usr/bin/pip3 /usr/bin/pip \
RUN ln -s /usr/bin/python3 /usr/bin/python

ADD about.json $ZEPPELIN_NOTEBOOK_DIR/2BTRWA9EV/note.json

VOLUME  $ZEPPELIN_LOGS_DIR \
        $ZEPPELIN_NOTEBOOK_DIR

WORKDIR $ZEPPELIN_HOME
CMD ["bin/zeppelin.sh"]
