#!/bin/sh
if [ "$1" == "initCluster" ]; then
  mongo m1.shard1.mongocluster:10011/cluster_test create_cluster.js
elif [ "$1" == "stop" ]; then
	pkill -15 -F proc/r1_pid
	pkill -15 -F proc/r2_pid
	pkill -15 -F proc/r3_pid
	pkill -15 -F proc/c1_pid
	pkill -15 -F proc/c2_pid
	pkill -15 -F proc/c3_pid
	pkill -15 -F proc/s1m1_pid
	pkill -15 -F proc/s1m2_pid
	pkill -15 -F proc/s1m3_pid
	pkill -15 -F proc/s2m1_pid
	pkill -15 -F proc/s2m2_pid
	pkill -15 -F proc/s2m3_pid
elif [ "$1" == "start" ]; then
	mkdir -p proc data/shard/c1/data/configdb data/shard/c1/logs data/shard/c2/data/configdb data/shard/c2/logs data/shard/c3/data/configdb data/shard/c3/logs 
	mkdir -p data/shard/r1/logs data/shard/r2/logs data/shard/r3/logs 
	mkdir -p data/shard1/m1/data data/shard1/m1/logs data/shard1/m2/data data/shard1/m2/logs data/shard1/m3/data data/shard1/m3/logs 
	mkdir -p data/shard2/m1/data data/shard2/m1/logs data/shard2/m2/data data/shard2/m2/logs data/shard2/m3/data data/shard2/m3/logs 

  #
  # config servers
  #
	echo Starting config server c1
  mongod --rest --config conf/c1.conf &
  # mongod --rest --configsvr --port 10101 --logpath=data/shard/c1/logs/mongod.log --dbpath=data/shard/c1/data/configdb --pidfilepath=proc/c1_pid --directoryperdb --nojournal --noprealloc
	# sleep 1

	echo
	echo Starting config server c2
	mongod --rest --config conf/c2.conf &
	# sleep 1

	echo
	echo Starting config server c3
	mongod --rest --config conf/c3.conf &
	sleep 3

  #
  # routing servers
  #
	echo
	echo Starting router server r1
	mongos --config conf/r1.conf &
	# sleep 1

	echo
	echo Starting router server r2
	mongos --config conf/r2.conf &
	# sleep 1

	echo
	echo Starting router server r3
	mongos --config conf/r3.conf &
	sleep 2

	echo
	echo Starting Shard1 m1
  mongod --rest --config conf/s1m1.conf &
  # mongod --dbpath data/shard1/m1/data/ --port 20000 --configsvr
	# sleep 1

	echo
	echo Starting Shard1 m2
	mongod --rest --config conf/s1m2.conf &
	# sleep 1

	echo
	echo Starting Shard1 m3
	mongod --rest --config conf/s1m3.conf &
	# sleep 1

	echo
	echo Starting Shard2 m1
	mongod --rest --config conf/s2m1.conf &
	# sleep 1

	echo
	echo Starting Shard2 m2
	mongod --rest --config conf/s2m2.conf &
	sleep 3

	echo
	echo Starting Shard2 m3
	mongod --rest --config conf/s2m3.conf &

else
	echo start or stop the entire MongoDB Sharded cluster:
	echo   "$0 [start|stop|initCluster]"
fi
