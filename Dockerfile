FROM ubuntu:14.04

MAINTAINER Meng Ding <dingmeng@gmail.com>

USER root

ENV HADOOP_VERSION 3.0.0-SNAPSHOT
ENV HADOOP_PREFIX /opt/hadoop
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

COPY add/config/* ${HADOOP_PREFIX}/etc/hadoop/

# Format hdfs
RUN ${HADOOP_PREFIX}/bin/hdfs namenode -format

# Copy all config files to /hadoop-config
RUN mkdir -p /hadoop-config \
    && cp -ar ${HADOOP_PREFIX}/etc/hadoop/* /hadoop-config

# Folder to share files
RUN mkdir /root/shared && \
    chmod a+rwX /root/shared

COPY bootstrap.sh /

ENTRYPOINT ["/bootstrap.sh"]

