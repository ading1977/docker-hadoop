#!/bin/bash

: ${HADOOP_CUSTOM_CONFIG:=/root/shared/hadoop}


function docker_hadoop_error
{
  echo "$*" 1>&2
}

function docker_hadoop_usage
{
  echo "Usage: runHadoop.sh (namenode | datanode | resourcemanager | nodemanager)"
}

if [[ $# = 0 ]]; then
  docker_hadoop_usage
  exit 1
fi

DAEMON=$1
case ${DAEMON} in
  namenode)
    docker run -d --name namenode --net=host \
      -e "HADOOP_CUSTOM_CONFIG=${HADOOP_CUSTOM_CONFIG}" \
      -v /opt/hadoop/logs:/opt/hadoop/logs \
      -v /root/shared:/root/shared \
      ading1977/hadoop:latest namenode
#      -p 50070:50070 \
#      -p 9000:9000 \
#      ading1977/hadoop:latest namenode
  ;;
  datanode)
    docker run -d --name datanode --net=host \
      -e "HADOOP_CUSTOM_CONFIG=${HADOOP_CUSTOM_CONFIG}" \
      -v /opt/hadoop/logs:/opt/hadoop/logs \
      -v /root/shared:/root/shared \
      ading1977/hadoop:latest datanode
#      -p 50075:50075 \
#      -p 50010:50010 \
#      -p 50020:50020 \
#      ading1977/hadoop:latest datanode
  ;;
  *)
    docker_hadoop_usage
    exit 1
  ;;
esac
