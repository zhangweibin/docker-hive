#!/bin/bash

/opt/hadoop-2.7.4/sbin/mr-jobhistory-daemon.sh start historyserver
/opt/hadoop-2.7.4/bin/yarn --config /etc/hadoop timelineserver
