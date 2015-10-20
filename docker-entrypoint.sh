#!/bin/bash

# Clean pid files
rm -rf /tmp/hadoop*

cp ${HADOOP_CUSTOM_CONFIG}/* ${HADOOP_PREFIX}/etc/hadoop/

case $1 in
  namenode)
    ${HADOOP_PREFIX}/bin/hdfs --daemon start namenode 
  ;;
  datanode)
    ${HADOOP_PREFIX}/bin/hdfs --daemon start datanode
  ;;
  *)
  /bin/bash
  ;;  
esac

while true; do sleep 1000; done
