#!/bin/bash

log() {
  echo $(date) $@
}

init_data() {
  if find ${HADOOP_DATA_DIR} -maxdepth 0 -empty | read; then
    log "Initializing hadoop data"
    tar xf /tmp/hadoop-data.tar -C ${HADOOP_DATA_DIR}
  fi
  rm -f /tmp/hadoop-data.tar
}

init_hadoop_config() {
  if find ${HADOOP_CONF_DIR} -maxdepth 0 -empty | read; then
    log "Initializing hadoop config"
    tar xf /tmp/hadoop-config.tar -C ${HADOOP_CONF_DIR}
    # Modify configuration files
    local CORE_SITE=${HADOOP_CONF_DIR}/core-site.xml
    local OLD_CORE_SITE=${HADOOP_CONF_DIR}/core-site.xml.old
    local HDFS_SITE=${HADOOP_CONF_DIR}/hdfs-site.xml
    local OLD_HDFS_SITE=${HADOOP_CONF_DIR}/hdfs-site.xml.old
    local YARN_SITE=${HADOOP_CONF_DIR}/yarn-site.xml
    local OLD_YARN_SITE=${HADOOP_CONF_DIR}/yarn-site.xml.old

    mv ${CORE_SITE} ${OLD_CORE_SITE}
    sed s/@NAMENODE@/${CONF_NAMENODE}/g ${OLD_CORE_SITE} \
      | sed s/@ZKQUORUM@/${CONF_ZK_QUORUM}/g - > ${CORE_SITE}
    mv ${HDFS_SITE} ${OLD_HDFS_SITE}
    sed s/@REPLICATION@/${CONF_DFS_REPLICATION}/g ${OLD_HDFS_SITE} > ${HDFS_SITE}
    mv ${YARN_SITE} ${OLD_YARN_SITE}
    sed s/@RESOURCEMANAGER@/${CONF_RESOURCEMANAGER}/g ${OLD_YARN_SITE} \
      | sed s/@PROXYSERVER@/${CONF_PROXYSERVER}/g - \
      | sed s/@TIMELINESERVER@/${CONF_TIMELINESERVER}/g - > ${YARN_SITE}
  fi
  rm -f /tmp/hadoop-config.tar
}

init_docker() {
  if [ $CONF_ENABLE_DOCKER_IN_DOCKER != true ]; then
    return 0
  fi
  if [ -n $DOCKER_BIN_DIR ]; then
    if [ -e "/usr/bin/docker" ]; then
      rm -f /usr/bin/docker
      ln -s $DOCKER_BIN_DIR/docker /usr/bin/docker
    fi
  fi
}

die() {
  log "Stopping $DAEMON ..."
  if do_action "stop"; then
    log "Stopped $DAEMON"
  fi
  exit 1
}

do_action() {
  action=$1
  # Clean pid files in case hadoop daemon is not gracefully shut down
  rm -rf /tmp/hadoop*.pid
  # Start daemon
  case $DAEMON in
    namenode)
      JPS_CLASS=NameNode
      $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs $1 namenode
    ;;
    datanode)
      JPS_CLASS=DataNode
      $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs $1 datanode
    ;;
    resourcemanager)
      JPS_CLASS=ResourceManager
      $HADOOP_PREFIX/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR $1 resourcemanager
    ;;
    proxyserver)
      JPS_CLASS=WebAppProxyServer
      $HADOOP_PREFIX/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR $1 proxyserver
    ;;
    nodemanager)
      JPS_CLASS=NodeManager
      $HADOOP_PREFIX/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR $1 nodemanager
    ;;
    zookeeper)
      JPS_CLASS=QuorumPeerMain
      ${ZK_PREFIX}/bin/zkServer.sh $1
    ;;
    *)
      log "Unrecognized daemon $DAEMON"
      return 1
    ;;
  esac
  return $?
}

init() {
  # Initialize hdfs data if needed
  init_data
  # Initialize configuration files if needed
  init_hadoop_config
  # Initialize docker
  init_docker
}


# Initialization
init

DAEMON=$1

# Run shell if no daemon is being passed in
if [ -z $DAEMON ]; then
  exec /bin/bash
fi

# Trap signal
trap die SIGHUP SIGINT SIGTERM
log "Starting $DAEMON ..."
# Start daemon
if ! do_action "start"; then
  exit 1
fi
log "Started $DAEMON"

# Minitor daemon liveliness
while true; do
  if jps | grep $JPS_CLASS > /dev/null; then
    sleep 15
  else
    log "$DAEMON has exited unexpectedly"
    exit 1
  fi
done
