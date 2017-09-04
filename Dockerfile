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
#ENV R_BASE_VERSION 3.3.2
# Appends the CRAN repository to your sources.list file
# You could replace jessie-cran3 by the newer one
# Find the correct value at https://cloud.r-project.org/
# RUN echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran3/" >> /etc/apt/sources.list
RUN echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran34/" >> /etc/apt/sources.list
#RUN apt-key adv --keyserver subkeys.pgp.net --recv-key 381BA480
## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
RUN apt-get update
#RUN apt-get install -y \
#        r-base=${R_BASE_VERSION}* \
#        r-base-dev=${R_BASE_VERSION}*
RUN apt-get install -y --force-yes r-base r-base-dev
#RUN apt-get install -y r-base r-base-dev
#RUN apt-get install -t unstable -y --no-install-recommends \
#		littler \
#                r-cran-littler \
#		r-base=${R_BASE_VERSION}* \
#		r-base-dev=${R_BASE_VERSION}* \
#		r-recommended=${R_BASE_VERSION}*
#RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site
#RUN echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
#RUN ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r
#RUN ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r
#RUN ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r
#RUN ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r
#RUN install.r docopt \
#RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
#RUN rm -rf /var/lib/apt/lists/*

# consider of CRAN below:
# https://mirrors.tuna.tsinghua.edu.cn/CRAN/
# http://mirrors.ustc.edu.cn/CRAN/
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

#ARG DIST_MIRROR=http://archive.apache.org/dist/zeppelin
# use internal mirror of ustc
ARG DIST_MIRROR=http://mirrors.ustc.edu.cn/apache/zeppelin
ARG VERSION=0.7.2

#ENV ZEPPELIN_HOME=/opt/zeppelin
# RUN mkdir -p   /tmp/zeppelin
RUN mkdir -p $ZEPPELIN_HOME
#RUN wget ${DIST_MIRROR}/zeppelin-${VERSION}/zeppelin-${VERSION}-bin-all.tgz | tar xvz -C ${ZEPPELIN_HOME}
RUN curl http://192.168.206.113:8000/zeppelin-${VERSION}-bin-all.tgz | tar xvz -C ${ZEPPELIN_HOME}
#RUN curl http://192.168.0.107:8000/zeppelin-${VERSION}-bin-all.tgz | tar xvz -C /tmp/zeppelin
#RUN mv /tmp/zeppelin/zeppelin-${VERSION}-bin-all/* ${ZEPPELIN_HOME}
#RUN cp -r ${ZEPPELIN_HOME}/zeppelin-${VERSION}-bin-all/* ${ZEPPELIN_HOME}/
#RUN rm -rf /tmp/zeppelin/zeppelin-${VERSION}-bin-all
RUN cp -r ${ZEPPELIN_HOME}/zeppelin-${VERSION}-bin-all/* ${ZEPPELIN_HOME}
RUN rm -rf ${ZEPPELIN_HOME}/zeppelin-${VERSION}-bin-all
RUN rm -rf *.tgz
RUN rm -rf /var/cache/apk/*
#RUN git clone https://github.com/apache/zeppelin.git /usr/src/zeppelin
# && cd /usr/src/zeppelin
#RUN cd /usr/src/zeppelin && git checkout -q $ZEPPELIN_COMMIT
#RUN /usr/src/zeppelin/dev/change_scala_version.sh $SCALA_VERION
#RUN MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m"
#RUN /tmp/apache-maven-$MAVEN_VERION/bin/mvn --batch-mode package -DskipTests -Pscala-$SCALA_VERION -Pbuild-distr
#RUN MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=1024m" /tmp/apache-maven-$MAVEN_VERION/bin/mvn --batch-mode package -DskipTests -Dspark.version=${SPARK_VERSION} -Dhadoop.version=${HADOOP_VERSION} \
#    -Pr -Psparkr -Pscala-$SCALA_VERION -Pbuild-distr
#  -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-display,spark-dependencies,spark,markdown,angular,shell,hbase,postgresql,jdbc,python,elasticsearch,zeppelin-web,zeppelin-server,zeppelin-distribution'
# Note by kay, here, we use the same commands that creates official binary package.
# mvn -e -Pscala-2.11 -Pspark-${SPARK_ZEPPELIN_VERSION} -Phadoop-${MAJOR_HADOOP_VERSION} -Psparkr -Pr -Pyarn -Ppyspark -DskipTests -Pvendor-repo package && \
# RUN /tmp/apache-maven-$MAVEN_VERION/bin/mvn clean package -DskipTests -Pspark-$SPARK_VERSION -Phadoop-$HADOOP_VERSION -Pr-$R_BASE_VERSION -Pscala-$SCALA_VERION -Psparkr -Pyarn -Ppyspark
#RUN /tmp/apache-maven-$MAVEN_VERION/bin/mvn -Pscala-${SCALA_VERION} -Pspark-${SPARK_VERSION} -Phadoop-${HADOOP_VERSION} -Pr-$R_BASE_VERSION -Psparkr -Pyarn -Ppyspark -DskipTests -Pvendor-repo package
#RUN tar xvf /usr/src/zeppelin/zeppelin-distribution/target/zeppelin*.tar.gz -C /usr/
#RUN mv /usr/zeppelin* $ZEPPELIN_HOME
RUN mkdir -p $ZEPPELIN_LOGS_DIR
RUN mkdir -p $ZEPPELIN_RUN_DIR
#RUN apt-get purge -y --auto-remove $buildDeps
#RUN rm -rf /var/lib/apt/lists/*
#RUN rm -rf /usr/src/zeppelin
#RUN rm -rf /root/.m2
#RUN rm -rf /root/.npm
#RUN rm -rf /tmp/*

# note this is the reference from another image
#RUN git clone --depth 1 --branch ${ZEPPELIN_VERSION} https://github.com/apache/zeppelin.git /zeppelin && \
#    apt-get update && \
#    apt-get install -y maven && \
#    mvn  -Pscala-2.11 -Pspark-${SPARK_ZEPPELIN_VERSION} -Phadoop-${MAJOR_HADOOP_VERSION} -Psparkr -Pyarn -Ppyspark -DskipTests -Pvendor-repo clean package && \
#    apt-get install -y python-matplotlib && \
#    echo "tail -F /zeppelin/logs/*" >> bin/zeppelin-daemon.sh && \
#    mkdir ~/.config/matplotlib && \
#    echo "backend : Agg" >> ~/.config/matplotlib/matplotlibrc

RUN ln -sf /usr/bin/pip3 /usr/bin/pip
RUN ln -sf /usr/bin/python3 /usr/bin/python

ADD about.json $ZEPPELIN_NOTEBOOK_DIR/2BTRWA9EV/note.json


#ENV ZEPPELIN_HOME /usr/zeppelin/zeppelin-${VERSION}-bin-all
#ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
#ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook

#RUN export ZEPPELIN_HOME=/usr/zeppelin/zeppelin-${VERSION}-bin-all

# Pid dir doesn't exist, create /usr/zeppelin/run
#RUN mkdir -p $ZEPPELIN_RUN_DIR

VOLUME  $ZEPPELIN_LOGS_DIR \
        $ZEPPELIN_NOTEBOOK_DIR

WORKDIR ${ZEPPELIN_HOME}
CMD ./bin/zeppelin.sh run
