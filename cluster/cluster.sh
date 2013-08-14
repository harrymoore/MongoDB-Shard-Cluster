#!/bin/sh
if [ $1 == "stop" ]; then
	pkill -F proc/r1_pid
	pkill -F proc/r2_pid
	pkill -F proc/r3_pid
	pkill -F proc/c1_pid
	pkill -F proc/c2_pid
	pkill -F proc/c3_pid
	pkill -F proc/s1m1_pid
	pkill -F proc/s1m2_pid
	pkill -F proc/s1m3_pid
	pkill -F proc/s2m1_pid
	pkill -F proc/s2m2_pid
	pkill -F proc/s2m3_pid
elif [ $1 == "start" ]; then
	echo Starting config server c1
	mongod --config conf/c1.conf &
	sleep 2

	echo
	echo Starting config server c2
	mongod --config conf/c2.conf &
	sleep 2

	echo
	echo Starting config server c3
	mongod --config conf/c3.conf &
	sleep 2

	echo
	echo Starting router server r1
	mongos --config conf/r1.conf &
	sleep 2

	echo
	echo Starting router server r2
	mongos --config conf/r2.conf &
	sleep 2

	echo
	echo Starting router server r3
	mongos --config conf/r3.conf &
	sleep 2

	echo
	echo Starting Shard1 m1
	mongod --config conf/s1m1.conf &
	sleep 2

	echo
	echo Starting Shard1 m2
	mongod --config conf/s1m2.conf &
	sleep 2

	echo
	echo Starting Shard1 m3
	mongod --config conf/s1m3.conf &
	sleep 2

	echo
	echo Starting Shard2 m1
	mongod --config conf/s2m1.conf &
	sleep 2

	echo
	echo Starting Shard2 m2
	mongod --config conf/s2m2.conf &
	sleep 2

	echo
	echo Starting Shard2 m3
	mongod --config conf/s2m3.conf &
else
	echo start or stop the entire MongoDB Sharded cluster:
	echo   "$0 [start|stop]"
fi
