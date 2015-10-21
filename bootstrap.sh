#!/bin/bash

# Clean pid files
rm -rf /tmp/hadoop*.pid

# Modify configuration files
CORE_SITE=${HADOOP_PREFIX}/etc/hadoop/core-site.xml
OLD_CORE_SITE=${HADOOP_PREFIX}/etc/hadoop/core-site.xml.old
HDFS_SITE=${HADOOP_PREFIX}/etc/hadoop/hdfs-site.xml
OLD_HDFS_SITE=${HADOOP_PREFIX}/etc/hadoop/hdfs-site.xml.old
YARN_SITE=${HADOOP_PREFIX}/etc/hadoop/yarn-site.xml
OLD_YARN_SITE=${HADOOP_PREFIX}/etc/hadoop/yarn-site.xml.old

mv ${CORE_SITE} ${OLD_CORE_SITE}
sed s/@HOSTNAME@/${HADOOP_NAMENODE}/ ${OLD_CORE_SITE} > ${CORE_SITE}
mv ${HDFS_SITE} ${OLD_HDFS_SITE}
sed s/@REPLICATION@/${HADOOP_DFS_REPLICATION}/ ${OLD_HDFS_SITE} > ${HDFS_SITE}
mv ${YARN_SITE} ${OLD_YARN_SITE}
sed s/@HOSTNAME@/${HADOOP_RESOURCEMANAGER}/ ${OLD_YARN_SITE} > ${YARN_SITE}

# Startup daemons
case $1 in
  namenode)
    ${HADOOP_PREFIX}/bin/hdfs --daemon start namenode 
  ;;
  datanode)
    ${HADOOP_PREFIX}/bin/hdfs --daemon start datanode
  ;;
  resourcemanager)
    ${HADOOP_PREFIX}/bin/yarn --daemon start resourcemanager 
  ;;   
  nodemanager)
    ${HADOOP_PREFIX}/bin/yarn --daemon start nodemanager 
  ;;
  *)
  /bin/bash
  ;;  
esac

while true; do sleep 1000; done
