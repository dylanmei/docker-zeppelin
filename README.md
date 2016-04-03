# zeppelin

A `debian:jessie` based Spark [Zeppelin](http://zeppelin.incubator.apache.org) Docker container.

This image is large and opinionated. It contains

- [Spark 1.6.1](http://spark.apache.org/docs/1.6.1) and [Hadoop 2.6.3](http://hadoop.apache.org/docs/r2.6.3)
- [PySpark](http://spark.apache.org/docs/1.6.1/api/python) support with Python3, [NumPy](http://www.numpy.org), and [SciPy](https://www.scipy.org/scipylib/index.html), but no matplotlib.
- A partial list of interpreters out-of-the-box. If your favorite interpreter isn't included, consider [adding it with the api](http://zeppelin.incubator.apache.org/docs/0.6.0-incubating-SNAPSHOT/manual/dynamicinterpreterload.html).
  - spark
  - shell
  - angular
  - postgresql
  - jdbc
  - hive
  - hbase
  - elasticsearch

A prior build of `dylanmei/zeppelin:latest` contained Spark 1.6.0 and **all** of the avaialble interpreters. That image is still available as `dylanmei/zeppelin:0.6.0-stable`.

## simple usage

To start Zeppelin pull the `latest` image and run the container:

```
docker pull dylanmei/zeppelin
docker run --rm --name zeppelin -p 8080:8080 dylanmei/zeppelin
```

Zeppelin will be running at `http://${YOUR_DOCKER_HOST}:8080`.

## complex usage

You can use [docker-compose](http://docs.docker.com/compose) to easily run Zeppelin in more complex configurations. See this project's `./examples` directory for examples of using Zeppelin with `docker-compose`:

- to read and write from local data files
- to read and write documents in ElasticSearch

## onbuild

The Docker `onbuild` container is still a part of this project, but **I have no plans to keep it updated**. See the `onbuild` directory to view its `Dockerfile`.

To use it, create a new `Dockerfile` based on `dylanmei/zeppelin:onbuild` and supply a new, executable `install.sh` file in the same directory. It will override the base one via Docker's [ONBUILD](https://docs.docker.com/reference/builder/#onbuild) instruction.

The steps, expressed here as a script, can be as simple as:

```
#!/bin/bash
cat > ./Dockerfile <<DOCKERFILE
FROM dylanmei/zeppelin:onbuild

ENV ZEPPELIN_MEM="-Xmx1024m"
DOCKERFILE

cat > ./install.sh <<INSTALL
git pull
mvn clean package -DskipTests \
  -Pspark-1.5 \
  -Dspark.version=1.5.2 \
  -Phadoop-2.2 \
  -Dhadoop.version=2.0.0-cdh4.2.0 \
  -Pyarn
INSTALL

docker build -t my_zeppelin .
```

## license

MIT
