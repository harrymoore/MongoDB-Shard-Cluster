#!/bin/bash
MONGOS1_PORT=10201
MONGOS1_HOST=r1.shard.mongocluster
MONGOS2_PORT=10202
MONGOS2_HOST=r2.shard.mongocluster
MONGOS3_PORT=10203
MONGOS3_HOST=r3.shard.mongocluster
MONGO_C1_PORT=10101
MONGO_C1_HOST=c1.shard.mongocluster
MONGO_C2_PORT=10102
MONGO_C2_HOST=c2.shard.mongocluster
MONGO_C3_PORT=10103
MONGO_C3_HOST=c3.shard.mongocluster
MONGO_S1_M1_PORT=10011
MONGO_S1_M1_HOST=m1.shard1.mongocluster
MONGO_S2_M1_PORT=10021
MONGO_S2_M1_HOST=m1.shard2.mongocluster

SHARDED_DB='sharded-db'
SHARDED_COL='sharded-collection'

if [[ "$1" = "" || "$1" = "-h" || "$1" = "--help"  ]]; then
  echo start, stop, initiate or wipe the entire MongoDB Sharded cluster:
  echo "$0 [start|stop|initiate|wipe]"
  exit 1
  
elif [[ "$1" = "stop" || "$1" = "wipe" ]]; then
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
	
elif [[ $1 == "start" ]]; then
	mkdir -p proc data/shard/c1/data/configdb data/shard/c1/logs data/shard/c2/data/configdb data/shard/c2/logs data/shard/c3/data/configdb data/shard/c3/logs 
	mkdir -p data/shard/r1/logs data/shard/r2/logs data/shard/r3/logs 
	mkdir -p data/shard1/m1/data data/shard1/m1/logs data/shard1/m2/data data/shard1/m2/logs data/shard1/m3/data data/shard1/m3/logs 
	mkdir -p data/shard2/m1/data data/shard2/m1/logs data/shard2/m2/data data/shard2/m2/logs data/shard2/m3/data data/shard2/m3/logs 

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
	sleep 2

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
	
	# start mms agent
	nohup python /usr/share/mms-agent/agent.py > ./agent.log  2>&1 &

  elif [[ $1 == "initiate-rs" ]]; then

    # initate replicaSets
    mongo --host ${MONGO_S1_M1_HOST} --port ${MONGO_S1_M1_PORT} --eval "rs.initiate()"
    sleep 10
    mongo --host ${MONGO_S1_M1_HOST} --port ${MONGO_S1_M1_PORT} --eval "rs.add('m2.shard1.mongocluster:10012')"
    mongo --host ${MONGO_S1_M1_HOST} --port ${MONGO_S1_M1_PORT} --eval "rs.add('m3.shard1.mongocluster:10013')"
    
    mongo --host ${MONGO_S2_M1_HOST} --port ${MONGO_S2_M1_PORT} --eval "rs.initiate()"
    sleep 10
    mongo --host ${MONGO_S2_M1_HOST} --port ${MONGO_S2_M1_PORT} --eval "rs.add('m2.shard1.mongocluster:10022')"
    mongo --host ${MONGO_S2_M1_HOST} --port ${MONGO_S2_M1_PORT} --eval "rs.add('m3.shard1.mongocluster:10023')"

  elif [[ $1 == "initiate-shard" ]]; then

    # add each of the 2 replica sets as a shard
    mongo --host r1.shard.mongocluster --port 10201 --eval "db.runCommand( { addShard: 'shard1/m1.shard1.mongocluster:10011', maxSize: 1, name: 'shard1'} )"
    mongo --host r1.shard.mongocluster --port 10201 --eval "db.runCommand( { addShard: 'shard2/m1.shard2.mongocluster:10021', maxSize: 1, name: 'shard2'} )"

    # enable sharding for database "sharded-db" and collection "sharded-collection"
    mongo --host r1.shard.mongocluster --port 10201 --eval "db.runCommand( { enableSharding: 'sharded-db' } )"
    mongo --host r1.shard.mongocluster --port 10201 --eval "sh.shardCollection('sharded-db.sharded-collection', { 'shard-key': 1} )"

else
	echo start, stop, initiate or wipe the entire MongoDB Sharded cluster:
	echo   "$0 [start|stop|initiate|wipe]"
fi

if [[ $1 == "wipe" ]]; then
  # start from scratch
  # wipe the data and logs for each mongod and mongos process
  # ToDo
  echo `pwd`;
  echo $0;
fi
