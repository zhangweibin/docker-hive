#!/bin/bash

hadoop fs -mkdir       /tmp
hadoop fs -mkdir -p    /user/hive/warehouse
hadoop fs -chmod g+w   /tmp
hadoop fs -chmod g+w   /user/hive/warehouse

hadoop fs -mkdir -p    /apps/tez
hadoop fs -put         /opt/tez/share/tez.tar.gz /apps/tez/tez.tar.gz

cp $HADOOP_CONF_DIR/core-site.xml /etc/impala/conf/
cp $HADOOP_CONF_DIR/hdfs-site.xml /etc/impala/conf/
cp $HIVE_HOME/conf/hive-site.xml /etc/impala/conf/

/bin/bash -c 'exec /etc/init.d/impala-state-store start'
/bin/bash -c 'exec /etc/init.d/impala-catalog start'
/bin/bash -c 'exec /etc/init.d/impala-server start'

cd $HIVE_HOME/bin
./hiveserver2 --hiveconf hive.server2.enable.doAs=false
