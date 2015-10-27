FROM ubuntu:14.04

MAINTAINER Meng Ding <dingmeng@gmail.com>

USER root

ENV HADOOP_VERSION 3.0.0-SNAPSHOT
ENV HADOOP_PREFIX /opt/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_PREFIX}/etc/hadoop
ENV HADOOP_DATA_DIR /var/lib/hadoop
ENV PATH ${HADOOP_PREFIX}/bin:$PATH

# Install all dependencies
RUN apt-get update && apt-get install -y \
    curl \
    openjdk-7-jdk \
    rsync \
    ssh \
    wget

# Download hadoop
RUN curl -SL https://s3.amazonaws.com/hadoop-distribution/hadoop-${HADOOP_VERSION}.tar.gz \
    | tar xz -C /opt

# Install hadoop
RUN ln -s /opt/hadoop-${HADOOP_VERSION} ${HADOOP_PREFIX} \
    && mkdir /var/lib/hadoop && mkdir /var/lib/hadoop/namenode \
    && mkdir /var/lib/hadoop/datanode

# Format hdfs
COPY add/config/* ${HADOOP_PREFIX}/etc/hadoop/
RUN ${HADOOP_PREFIX}/bin/hdfs namenode -format

# Copy data and configuration to be used by container initialization
RUN tar cf /tmp/hadoop-data.tar -C ${HADOOP_DATA_DIR} . \
    && tar cf /tmp/hadoop-config.tar -C ${HADOOP_CONF_DIR} .

COPY bootstrap.sh /

ENTRYPOINT ["/bootstrap.sh"]

