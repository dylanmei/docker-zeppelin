
# zeppelin

A `debian:jessie` based Spark [Zeppelin](http://zeppelin.incubator.apache.org) Docker container.

# usage

Pull the image and run the container:

```
docker pull dylanmei/zeppelin:master
docker run --name zeppelin -p 8080:8080 -p 8081:8081 dylanmei/zeppelin:master
```

By default, Zeppelin wants to use ports 8080-8081. So do a lot of other things, including a Spark master UI. Change the ports Zeppelin uses by specifying `--environment "ZEPPELIN_PORT="8090"` to `docker run`. For example:

```
docker run --name zeppelin -e "ZEPPELIN_PORT=8090" -p 8090:8090 -p 8091:8091 dylanmei/zeppelin:master
```

# customize

Forking this project to change Spark/Hadoop versions is unnecessary! Instead, create a `Dockerfile` based on `dylanmei/zeppelin:master` and supply a new `install.sh` file in the same directory. It will override the base one via Docker's [ONBUILD](https://docs.docker.com/reference/builder/#onbuild) instruction.

The steps, expressed here as bash, can be as simple as:

```
cat > ./Dockerfile <<DOCKERFILE
FROM dylanmei/zeppelin:master

ENV ZEPPELIN_MEM="-Xmx1024m"
DOCKERFILE

cat > ./install.sh <<INSTALL
mvn clean package -DskipTests \
  -Pspark-1.2 \
  -Dspark.version=1.2.1 \
  -Phadoop-2.2 \
  -Dhadoop.version=2.0.0-cdh4.2.0
  -Pyarn
INSTALL

docker build -t my_zeppelin .
```

## license

MIT
