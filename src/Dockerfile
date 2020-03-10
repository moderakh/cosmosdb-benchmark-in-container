FROM ubuntu:18.04
RUN apt-get update && apt-get install -y openjdk-8-jdk net-tools vim
COPY ./azure-cosmos-benchmark-4.0.1-beta.1-jar-with-dependencies.jar /usr/app/
COPY ./run.sh /usr/app/
WORKDIR /usr/app
CMD /bin/sh ./run.sh ReadThroughput 10
