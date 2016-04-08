#Spark-pi example
The aim of this example is to show how to run a Spark application in cluster mode on MANTL.

##Prerequisites 
* Install Spark via mantl-api:
```bash
curl -k -i -L -X POST -d "{\"name\": \"spark\"}" https://admin:password@control-node/api/1/install
```
>**Note**: in the previous command, don't forget to substitute *password* and *control-node* with the actual password, 
and the actual control node IP (or domain name) of your MANTL cluster.

* Install the GlusterFS addon: http://docs.mantl.io/en/latest/components/glusterfs.html

* Install the Chronos addon: http://docs.mantl.io/en/latest/components/chronos.html

* SSH into one of your nodes, and create a configuration file `/mnt/container-volumes/spark-conf/spark-defaults.conf` that 
looks someting like this:
```
spark.mesos.principal=mantl-api
spark.mesos.secret=your_mantl_cluster_mesos_secret
spark.mesos.executor.docker.volumes=/mnt/container-volumes/spark-conf:/opt/spark/dist/conf:ro
spark.mesos.executor.docker.image=mesosphere/spark:1.6.0
```
You can figure out the mesos secret form the *security.yml* file, that you created usining the *security-setup* script:
```bash
cat security.yml | grep mantl_api_secret
```

##Schedule the job using Chronos
To schedule Spark-pi using Chronos, please run:
```
./schedule.sh
```
>**Note**: in the *spark-pi.json* file, the spark-pi job is scheduled for the new year eve of 2030, therefore you might 
want to force its run from the Chronos API. In alternative, you can change this date in *spark-pi.json* before to run `./schedule.sh`.
