#!/bin/bash

: ${HADOOP_CONF_DIR:=/opt/hadoop/etc/hadoop}

init_config() {
  # Modify configuration files
  local CORE_SITE=${HADOOP_CONF_DIR}/core-site.xml
  local OLD_CORE_SITE=${HADOOP_CONF_DIR}/core-site.xml.old
  local HDFS_SITE=${HADOOP_CONF_DIR}/hdfs-site.xml
  local OLD_HDFS_SITE=${HADOOP_CONF_DIR}/hdfs-site.xml.old
  local YARN_SITE=${HADOOP_CONF_DIR}/yarn-site.xml
  local OLD_YARN_SITE=${HADOOP_CONF_DIR}/yarn-site.xml.old

  mv ${CORE_SITE} ${OLD_CORE_SITE}
  sed s/@HOSTNAME@/${CONF_NAMENODE}/ ${OLD_CORE_SITE} > ${CORE_SITE}
  mv ${HDFS_SITE} ${OLD_HDFS_SITE}
  sed s/@REPLICATION@/${CONF_DFS_REPLICATION}/ ${OLD_HDFS_SITE} > ${HDFS_SITE}
  mv ${YARN_SITE} ${OLD_YARN_SITE}
  sed s/@HOSTNAME@/${CONF_RESOURCEMANAGER}/ ${OLD_YARN_SITE} > ${YARN_SITE}
}

log() {
  echo $(date) $@
}

# Clean pid files
rm -rf /tmp/hadoop*.pid

# Initialize configuration files if needed
init_config

# Startup daemons
case $1 in
  namenode)
    JPS_CLASS=NameNode
    ${HADOOP_PREFIX}/bin/hdfs --daemon start namenode 
  ;;
  datanode)
    JPS_CLASS=DataNode
    ${HADOOP_PREFIX}/bin/hdfs --daemon start datanode
  ;;
  resourcemanager)
    JPS_CLASS=ResourceManager
    ${HADOOP_PREFIX}/bin/yarn --daemon start resourcemanager 
  ;;   
  nodemanager)
    JPS_CLASS=NodeManager
    ${HADOOP_PREFIX}/bin/yarn --daemon start nodemanager 
  ;;
  *)
  /bin/bash
  ;;  
esac

while true; do
  if jps | grep $JPS_CLASS; then
    sleep 15
  else
    log "$JPS_CLASS has exited unexpectedly"
    exit 1
  fi
done
