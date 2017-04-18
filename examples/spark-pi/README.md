#Spark-pi example
The aim of this example is to show how to run a Spark application in cluster mode on MANTL.

##Prerequisites 
* Install Spark via mantl-api:
```bash
curl -k -i -L -X POST -d "{\"name\": \"spark\"}" https://admin:password@control-node/api/1/install
```
>**Note**: in the previous command, don't forget to substitute *password* and *control-node* with the actual password, 
and the actual control node IP (or domain name) of your MANTL cluster.

* Install the Chronos addon: http://docs.mantl.io/en/latest/components/chronos.html

##Schedule the job using Chronos
To schedule Spark-pi using Chronos, please run:
```
./schedule.sh
```
>**Note** 
* In the *spark-pi.json* file, the spark-pi job is scheduled for the new year eve of 2030, therefore you might 
want to force its run from the Chronos API. In alternative, you can change this date in *spark-pi.json* before to run `./schedule.sh`
* In this example we use a custom Docker image to submit the job to the Spark dispatcher, via Chronos (https://github.com/mcapuccini/spark-container)
