FROM bde2020/hadoop-base:2.0.0-hadoop2.7.4-java8

MAINTAINER Yiannis Mouchakis <gmouchakis@iit.demokritos.gr>
MAINTAINER Ivan Ermilov <ivan.s.ermilov@gmail.com>

# Allow buildtime config of HIVE_VERSION
ARG HIVE_VERSION
ARG TEZ_VERSION
# Set HIVE_VERSION from arg if provided at build, env if provided at run, or default
# https://docs.docker.com/engine/reference/builder/#using-arg-variables
# https://docs.docker.com/engine/reference/builder/#environment-replacement
ENV HIVE_VERSION=${HIVE_VERSION:-2.3.5}
ENV TEZ_VERSION=${TEZ_VERSION:-0.9.2}

ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION

WORKDIR /opt

#Install Hive , TEZ and PostgreSQL JDBC
RUN curl -O http://mirror.bit.edu.cn/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
	tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
	mv apache-hive-$HIVE_VERSION-bin hive && \
	curl -o $HIVE_HOME/lib/postgresql-jdbc.jar https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar && \
	rm apache-hive-$HIVE_VERSION-bin.tar.gz && \
        curl -O http://mirror.bit.edu.cn/apache/tez/$TEZ_VERSION/apache-tez-$TEZ_VERSION-bin.tar.gz && \
        tar -xzvf apache-tez-$TEZ_VERSION-bin.tar.gz && \
        mv apache-tez-$TEZ_VERSION-bin tez && \
        rm apache-tez-$TEZ_VERSION-bin.tar.gz && \
        rm -f tez/lib/hadoop-mapreduce-client-c*.jar && \
        cp $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-c*.jar tez/lib

#Install Impala
ADD impala/sources.list /etc/apt
ADD impala/archive.key /opt
ADD impala/cloudera.list /etc/apt/sources.list.d
RUN apt-key add archive.key && \
        apt-get update && apt-get install -y impala impala-server impala-shell impala-catalog impala-state-store && \
        apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#Spark should be compiled with Hive to be able to use it
#hive-site.xml should be copied to $SPARK_HOME/conf folder

#Custom configuration goes here
ADD conf/tez-site.xml $HADOOP_CONF_DIR
ADD conf/hadoop-env.sh $HADOOP_CONF_DIR
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 10000
EXPOSE 10002
EXPOSE 21000
EXPOSE 21050
EXPOSE 25000
EXPOSE 25010
EXPOSE 25020

ENTRYPOINT ["entrypoint.sh"]
CMD startup.sh
