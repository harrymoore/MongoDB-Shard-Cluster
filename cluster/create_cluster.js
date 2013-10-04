// create_cluster.sh
// connect to mongo:
//   mongo --host m1.shard1.mongocluster --port 10011
// run this script:
//   load("create_cluster.sh");
use config;
db.settings.save( { _id:"chunksize", value: "5" } );

rs.initiate()

rs.add("m2.shard1.mongocluster:10012")
rs.add("m3.shard1.mongocluster:10013")
