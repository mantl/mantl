
# Examples

The examples in this directory are applications that can be run against your cluster.

In each example directory is a README.md that provides the short and sweet instructions. Below we go through
the examples in more detail and provide more of an introduction to what is going on.

## Getting a Cluster Up

#### Vagrant Cluster

Getting the vagrant cluster up and running on your laptop is the easiest way to get a cluster going
for the examples.

To do this, see Getting Started in the [README.md](../README.md) at root of this project.

If you have not done so yet, go ahead get vagrant up now. It will take a couple of minutes and you can read
on while you wait.

To run these examples you will need to know:

1. The url for marathon:
Marathon runs on port 8080 and if you look in the Vagrantfile in the root of this project there is a line:

        VAGRANT_PRIVATE_IP = "192.168.242.55"

2. User name and password for marathon:
After you have run`./security-setup` in the root of this project, there will be a file `security.yml`.
Inside this file is the line:

        marathon_http_credentials: admin:hardpass

During my run of `./security-setup` I was asked:

    $ ./security-setup
    ============= Certificates =============
    ----> certificate authority
    created serial
    created index
    generated root CA
    ================ Nginx =================
    ----> SSL certificate
    generated nginx key
    generated nginx CSR
    generated nginx certificate
    nginx certificate is valid
    ----> admin password
    Admin Password:


At that point I had entered 'hardpass'

### Other Clusters

If you want to dive right into a cloud or an openstack cluster go through
[Getting Started](https://microservices-infrastructure.readthedocs.org/en/latest/getting_started/index.html)
at the Documetation site.   You can then change the relevant parts of the following instructions.

### Submitting Applications to The Marathon API

While in a terminal, in this examples, directory enter:

    curl -k -X POST -H "Content-Type: application/json" "https://admin:hardpass@192.168.242.55:8080/v2/apps" -d@"hello-world/hello-world.json"

You should get back something like:

    {"id":"/hello-world","cmd":null,"args":null,"user":null,"env":{},"instances":2,"cpus":0.1,"mem":128.0,"disk":0.0,"executor":"","constraints":[],"uris":[],"storeUrls":[],"ports":[0],"requirePorts":false,"backoffFactor":1.15,"container":{"type":"DOCKER","volumes":[],"docker":{"image":"keithchambers/docker-hello-world","network":"BRIDGE","portMappings":[{"containerPort":80,"hostPort":0,"servicePort":0,"protocol":"tcp"}],"privileged":false,"parameters":[],"forcePullImage":false}},"healthChecks":[],"dependencies":[],"upgradeStrategy":{"minimumHealthCapacity":1.0,"maximumOverCapacity":1.0},"labels":{},"acceptedResourceRoles":null,"version":"2015-12-14T05:53:13.140Z","deployments":[{"id":"1b534972-53ee-4198-8860-ea0c48c3d7e9"}],"tasks":[],"tasksStaged":0,"tasksRunning":0,"tasksHealthy":0,"tasksUnhealthy":0,"backoffSeconds":1,"maxLaunchDelaySeconds":3600}

If not perhaps you messed up an option. Here is what they do:

Option -k turns off ssl certificate verification.  If you are using he Vagrantfile then you are getting a self
signed cert. If you forgot the -k you get this message:

    $ curl -X POST -H "Content-Type: application/json"  "https://admin:hardpass@192.168.242.55:8080/v2/apps" -d@"hello-world/hello-world.json"
    curl: (60) SSL certificate problem: Invalid certificate chain
    More details here: http://curl.haxx.se/docs/sslcerts.html

    curl performs SSL certificate verification by default, using a "bundle"
     of Certificate Authority (CA) public keys (CA certs). If the default
     bundle file isn't adequate, you can specify an alternate file
     using the --cacert option.
    If this HTTPS server uses a certificate signed by a CA represented in
     the bundle, the certificate verification probably failed due to a
     problem with the certificate (it might be expired, or the name might
     not match the domain name in the URL).
    If you'd like to turn off curl's verification of the certificate, use
     the -k (or --insecure) option.

Option -X allows you to specify a HTTP verb other than the default GET.. In this case we want to POST.  The following
error happens if we forget the -X or if the -d@"file.json" is not found. Perhaps because you are submiting the command from
the wrong directory.

    $ curl -k -H "Content-Type: application/json"  "https://admin:hardpass@192.168.242.55:8080/v2/apps" -d@"hello-world/hello-world.json"
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1"/>
    <title>Error 400 Bad Content-Type header value: 'application/json '</title>
    </head>
    <body>
    <h2>HTTP ERROR: 400</h2>
    <p>Problem accessing /v2/apps. Reason:
    <pre>    Bad Content-Type header value: 'application/json '</pre></p>
    <hr /><i><small>Powered by Jetty://</small></i>

Option -H specifies a header argument. In this case we want to set the content type to json.  If you leave this off
you will get:

    $ curl -k -X POST   "https://admin:hardpass@192.168.242.55:8080/v2/apps" -d@"hello-world/hello-world.json"
    curl: (6) Could not resolve host:  
    {"message":"Unsupported Media Type"}

### The Marathon API and the Application JSON

In the curl call we went to the following path `/v2/apps`. This is the api call for creating and starting new apps.
See [Marathon REST API](https://mesosphere.github.io/marathon/docs/rest-api.html) for further calls. Two handy ones
for our purposes are:

##### Current Status

From this REST API, get current status with:

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/hello-world"

which returns a big blob of json.  If you want this cleaned up a bit try adding `| python -m json.tool` :

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/hello-world" | python -m json.tool

That should give you a nicely formated output of the current state of the app.

Notice that we didn't need headers `-h` and the http verb was the default GET so we didn't need `-X`. We
still needed the -k to get around our self signed ssl certificate.

##### Delete App

From this REST API, the call to destroy the application is:

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/hello-world" -X DELETE

which is the same as the current status path but with the HTTP DELETE verb instead of the default GET.  If successful you
will get something like:

    {"version":"2015-12-14T06:44:37.378Z","deploymentId":"e7680e8e-d073-4c57-9f64-e73d8b634398"}

you could check the status again, per the previous section. It should give you `{"message":"App '/hello-world' does not exist"}`


## Where is my Application

In version 0.5.0 the vagrant build does not have traefik in it and so service discovery is a bit convoluted but not too
bad.

In a browser, go to the IP of your vagrant cluster. This will be the value in your Vagrantfile as described earlier.

![mantlui 192.168.242.55/ui](./images/mantlui.png)

Choose the Marathon "web UI" button and you should see:

![marathonui](./images/marathonui.png)

Click on your application, hello-world (Note: if its not there. you probably deleted it working through the steps above.
Just start it again. ) and you should see:

![marathonui at application](./images/marathonapp.png)

You'll notice that there are two instances.  Each one has a line under it in gray `default:<####>` where <####> is some
port number. In the picture above, ports 9061 and 25312.

One note.. there are two here becasue the hello-world.json file you submitted asks for two instances to be created.
This is two seperate hello-world applications.

If I click on the `default:9061` it will open my browser to default:9061 and get a `webpage is not avaiable` error.
This is because I don't have default mapped to 192.168.242.55 in my hosts file.  Rather than mess with that.  Lets just
take the port information and add it to the IP of where we know the vagrant "cluster" is located.   Open the browser to
 192.168.242.55:9061 (in this example) and we see:

 ![hello world application](./images/helloworld.png)


Note that it has the container # in it.  If you go back and look at marathon and get the other Port. This will take you
to the other container.  if you look into the json file for [hello world](hello-world/hello-world.json) you will see that
you are submiting a call to create two instances of a docker image. `"image": "keithchambers/docker-hello-world",`.  Google that
and you get to the [php code running in this container](https://github.com/keithchambers/docker-hello-world/blob/master/index.php).

## Destory the Vagrant Cluster and Build on for MineCraft

If you want to use the vagrant cluster for the Minecraft example you have to make it a bigger VM.  Minecraft requires
2 Gigs free for itself.

Easy enough!

1. Destroy your vagrant server. Go to the project root and type:

        vagrant destroy

2. Edit the vagrant file.

Change `Vagrantfile` lines near the bottom from

          config.vm.provider :virtualbox do |vb|
            vb.customize ['modifyvm', :id, '--cpus', 1]
            vb.customize ['modifyvm', :id, '--memory', 1536]
          end

to

          config.vm.provider :virtualbox do |vb|
            vb.customize ['modifyvm', :id, '--cpus', 2]
            vb.customize ['modifyvm', :id, '--memory', 3536]
          end


and then do:

        vagrant up


Once its up and happy..

    curl -k -X POST -H "Content-Type: application/json" "https://admin:hardpass@192.168.242.55:8080/v2/apps" -d@"minecraft/minecraft.json"

If you didn't add the memory.  The above would submit and you would get the json back. You could then go look at the marathon web
interface and you would see it Deploying but never getting anywhere.

![marathon stuck](images/marathonstuck.png)

Notice the /minecraft app has a Memory(MB) column value of 2048.  This app is requesting 2GB of RAM.  This value is from
the [json file you submitted](minecraft/minecraft.json) .

To investigate, go back to the mantlui (https://192.168.242.55) and then go to the Mesos "Web UI" button.

![mesos stuck](images/mesosstuck.png)

you see that no minecraft is running.  Then looking down the side you see that the total offered is 0 and there are
238 MB idle.   The request on the Marathon page above is for 2048 MB, there isn't enough and so the system just waits
for resources.

That is why we said to increase the RAM for minecraft and definitely something to keep in mind when you
see things getting stuck like that as you work with Mantl.  Marathon will take your request and wait patiently for Mesos
to have what you are asking for.  Make sure Mesos has what you are asking for.


With the right amount of memory and the minecraft successfully running, you can go back and look at the ports on the
marathon page as described above but you can also check the status:

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/minecraft" | python -m json.tool

Near the bottom of the listing there is a item for tasks. And there you will find:

    "tasks": [
                {
                    "appId": "/minecraft",
                    "healthCheckResults": [
                        {
                            "alive": true,
                            "consecutiveFailures": 0,
                            "firstSuccess": "2015-12-14T08:25:32.032Z",
                            "lastFailure": null,
                            "lastSuccess": "2015-12-14T08:25:32.032Z",
                            "taskId": "minecraft.1c820b04-a23c-11e5-bc5d-5e55552100a7"
                        }
                    ],
                    "host": "default",
                    "id": "minecraft.1c820b04-a23c-11e5-bc5d-5e55552100a7",
                    "ports": [
                        9199
                    ],
                    "stagedAt": "2015-12-14T08:24:36.469Z",
                    "startedAt": "2015-12-14T08:25:22.424Z",
                    "version": "2015-12-14T08:24:31.818Z"
                }
            ],

The task with appId "/minecraft"  on host "default" is listening on port 9199.

With that you can open your minecraft client, create a new server.  Set the "Server Address" to 192/168.242.55:9199.

You are now.. talking to an App, in a Docker Container submitted to a Mesos cluster by Marathon framework and all
running on a VM in Virtualbox.  Progress!  Happy mining.

One more way to get the the port would be to ssh to the vm, and look at docker ps.  So cd to the root of the project.

    vagrant ssh
    sudo docker ps

and in the list you will see.

    CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                                                                                              NAMES
    c0c6347a7ed4        kitematic/minecraft              "/bin/sh -c 'echo eul"   11 minutes ago      Up 11 minutes       0.0.0.0:9199->25565/tcp                                                                            mesos-20151214-082111-938649792-15050-7100-S0.5554ed92-e22c-4d26-94c9-2556dab6621b

this container has expose 25565 (the standard minecraft port) as 9199.











