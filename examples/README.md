
# Example

The examples in this directory are applications that can be run against your cluster.

In each directory is a README.md is the short and sweet instructions. Below go through in more detail and provide
more of an introduction to what is going on with these examples.

## Getting a Cluster Up

#### Vagrant Cluster

The easiest way to get going is to get a vagrant VM up and running with all the software.

see Getting Started in the [README.md](../README.md) at root of this project for instructions oh doing this.

If you have not done so yet, go ahead get vagrant up now. It will take a couple of minutes and you can come
back to this while you wait.

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

If you want to dive right into a cloud or openstack cluster go through  [Getting Started at the Documetation
site](https://microservices-infrastructure.readthedocs.org/en/latest/getting_started/index.html).   You can then
change the relevant parts of the following instructions.

### Submitting Applications to The Marathon API

While in the examples directory enter:

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

In the curl call we went to the directory `/v2/apps` this is the api call for creating and starting new apps.
See [Marathon REST API](https://mesosphere.github.io/marathon/docs/rest-api.html) for further calls.

##### Current Status

From this REST API the call to get the current status is.

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/hello-world"

which returns a big blob of json.  If you want this cleaned up a bit try adding `| python -m json.tool` :

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/hello-world" | python -m json.tool

That should give you a nicely formated output of the current state of the app.

Notice that we didn't need headers `-h`, the http verb was the default GET so we didn't need `-X` but we
still needed the -k to get around our self signed ssl certificate.

##### Delete App

From this REST API the call to destroy the application is.

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/hello-world" -X DELETE

which is the same as the above but with the HTTP DELETE verb instead of the default GET.  If successful you
will get something like:

    {"version":"2015-12-14T06:44:37.378Z","deploymentId":"e7680e8e-d073-4c57-9f64-e73d8b634398"}

you could check the status again, per the previous section. It should give you `{"message":"App '/hello-world' does not exist"}`


## Where is my Application

In version 0.5.0 the vagrant build does not have traefik in it and so service discovery is a bit convoluted but not to
bad.

Got to the IP of your vagrant cluster. This will be the value in your Vagrantfile as described earlier.

![mantlui 192.168.242.55/ui](./mantlui.png)

Choose the Marathon "web UI" button and you should see:

![marathonui](./marathonui.png)

Click on your application, hello-world (Note: if its not there. you probably deleted it working through the steps above.
Just start it again. ) and you should see:

![marathonui at application](./marathonapp.png)

You'll notice that there are two instances.  Each one has a line under it in gray `default:<####>` where <####> is some
port number. In the picture above, ports 9061 and 25312.

One note.. there are two here becasue the hello-world.json file asks for two instances to be created. This is two
seperate hello-world applications.

If I click on the `default:9061` it will open my browser to default:9061 and get a `webpage is not avaiable` error.
This is because I don't have default mapped to 192.168.242.55 in my hosts file.  Rather than mess with that.  Lets just
take the port information and add it to the IP of where we know the vagrant "cluster" is located.   Open the browser to
 192.168.242.55:9061 (in this example) and we see:

 ![hello world application](./helloworld.png)



