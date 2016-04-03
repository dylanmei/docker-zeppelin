# zeppelin

A `debian:jessie` based Spark [Zeppelin](http://zeppelin.incubator.apache.org) Docker container.

This image is large and opinionated. It contains

- [Spark 1.6.1](http://spark.apache.org/docs/1.6.1) and Hadoop 2.6.3
- [PySpark](http://spark.apache.org/docs/1.6.1/api/python) support with Python3, [NumPy](http://www.numpy.org), and [SciPy](https://www.scipy.org/scipylib/index.html), but no matplotlib support.
- All the interpreters. To specify exactly which interpreters to expose, use the `ZEPPELIN_INTERPRETERS` env variable. For example, `ZEPPELIN_INTERPRETERS=org.apache.zeppelin.spark.SparkInterpreter,org.apache.zeppelin.spark.SparkSqlInterpreter` will expose only the Spark and Spark SQL inerpreters.

## simple usage

To run Zeppelin in Spark local mode, pull the `latest` image and run the container:

```
docker pull dylanmei/zeppelin
docker run --rm --name zeppelin -p 8080:8080 dylanmei/zeppelin
```

Zeppelin will be running at `http://${YOUR_DOCKER_HOST}:8080`.

## complex usage

You can use [docker-compose](http://docs.docker.com/compose) to easily run Zeppelin in more complex configurations. See the `./examples` directory for examples of using Zeppelin:

- with the default tutorial
- with local data files
- with ElasticSearch

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
