#!/bin/bash

: ${HADOOP_CONF_DIR:=/opt/hadoop/etc/hadoop}

init_config() {
  cp -arf /hadoop-config/* ${HADOOP_CONF_DIR}

  # Modify configuration files
  local CORE_SITE=${HADOOP_CONF_DIR}/core-site.xml
  local OLD_CORE_SITE=${HADOOP_CONF_DIR}/core-site.xml.old
  local HDFS_SITE=${HADOOP_CONF_DIR}/hdfs-site.xml
  local OLD_HDFS_SITE=${HADOOP_CONF_DIR}/hdfs-site.xml.old
  local YARN_SITE=${HADOOP_CONF_DIR}/yarn-site.xml
  local OLD_YARN_SITE=${HADOOP_CONF_DIR}/yarn-site.xml.old

  mv ${CORE_SITE} ${OLD_CORE_SITE}
  sed s/@HOSTNAME@/${HADOOP_NAMENODE}/ ${OLD_CORE_SITE} > ${CORE_SITE}
  mv ${HDFS_SITE} ${OLD_HDFS_SITE}
  sed s/@REPLICATION@/${HADOOP_DFS_REPLICATION}/ ${OLD_HDFS_SITE} > ${HDFS_SITE}
  mv ${YARN_SITE} ${OLD_YARN_SITE}
  sed s/@HOSTNAME@/${HADOOP_RESOURCEMANAGER}/ ${OLD_YARN_SITE} > ${YARN_SITE}
}

# Clean pid files
rm -rf /tmp/hadoop*.pid

# Initialize configuration files if needed
mkdir -p ${HADOOP_CONF_DIR}
if find ${HADOOP_CONF_DIR} -maxdepth 0 -empty | read; then
  init_config
fi

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
