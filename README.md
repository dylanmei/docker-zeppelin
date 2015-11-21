
# zeppelin

A `debian:jessie` based Spark [Zeppelin](http://zeppelin.incubator.apache.org) Docker container.

## usage

Run the Zeppelin container in Spark local mode, or in a Spark cluster.

### local

Pull the image and run the container:

```
docker pull dylanmei/zeppelin:latest
docker run --name zeppelin -p 8080:8080 -p 8081:8081 dylanmei/zeppelin:latest
```

Or, using [docker-compose](http://docs.docker.com/compose):

```
docker-compose up
```

Zeppelin will be running at `http://${YOUR_DOCKER_HOST}:8080`.

## customize

Forking this project to change Spark/Hadoop versions is unnecessary! Instead, create a `Dockerfile` based on `dylanmei/zeppelin:master` and supply a new, executable `install.sh` file in the same directory. It will override the base one via Docker's [ONBUILD](https://docs.docker.com/reference/builder/#onbuild) instruction.

The steps, expressed here as a script, can be as simple as:

```
#!/bin/bash
cat > ./Dockerfile <<DOCKERFILE
FROM dylanmei/zeppelin:master

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
