# Examples

The examples in this directory are applications that can be run on your Mantl
cluster. See the README.md in each folder for a detailed walkthrough of running
them.

Below, we will explore some information that is useful when executing any of the
examples, and later, explore some next steps and more advanced usage.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Examples](#examples)
    - [General Information](#general-information)
        - [Creating a Mantl Cluster](#creating-a-mantl-cluster)
            - [Vagrant](#vagrant)
            - [Cloud](#cloud)
        - [IPs and URLs](#ips-and-urls)
            - [Vagrant](#vagrant)
            - [Cloud](#cloud)
        - [Usernames and Passwords](#usernames-and-passwords)
            - [Marathon](#marathon)
        - [Launching your app](#launching-your-app)
            - [With Marathon + Mesos](#with-marathon--mesos)
            - [With Kubernetes](#with-kubernetes)
        - [Finding your app](#finding-your-app)
            - [With Marathon + Mesos (CLI)](#with-marathon--mesos-cli)
            - [With Marathon + Mesos (Web UI)](#with-marathon--mesos-web-ui)
            - [With Kubernetes](#with-kubernetes)
        - [Possible Sticking Points](#possible-sticking-points)
            - [curl](#curl)
            - [Marathon + Mesos](#marathon--mesos)
    - [Going Further](#going-further)
        - [Using curl](#using-curl)
        - [Deleting Apps](#deleting-apps)
            - [Marathon](#marathon)
            - [Kubernetes](#kubernetes)
        - [MantlUI](#mantlui)

<!-- markdown-toc end -->

## General Information

### Creating a Mantl Cluster

#### Vagrant

A local Vagrant cluster is the easiest way to try Mantl. See
[the Getting Started guide](http://docs.mantl.io/en/latest/getting_started/vagrant.html)
for more information on building your cluster.

#### Cloud

See [the Getting Started guide](http://docs.mantl.io/en/latest/getting_started/index.html)
for more information on using a cloud provider.

### IPs and URLs

Marathon runs on `https://<your-control-ip>:8080` or
`https://<your-control-ip>/marathon`.

#### Vagrant

Check out the Vagrant README to figure out the IP addresses it will assign. If
you're using the default configuration, you'll have one control node at
"192.168.100.101" and one worker at "192.168.100.201".

#### Cloud

Run
```bash
./plugins/inventory/terraform.py --hostfile
```
to see the IP addresses of your nodes.

### Usernames and Passwords

#### Marathon

During your run of `./security-setup` you will be asked to set an admin
password:

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

which is the password used for Marathon.

If you forgot what you entered, look in `security.yml` for the line
```
marathon_http_credentials: admin:<your-marathon-password>
```

### Launching your app

#### With Marathon + Mesos

Run the following command from the mantl root directory:
```bash
curl -X POST \
     -H "Content-Type: application/json" \
     --cacert ssl/cacert.pem \
     -u "<user>:<pass>" \
     -d @examples/<your-app>/<your-app>.json \
     "https://<your-control-ip>:8080/v2/apps"
```
It may take a few minutes for Marathon to download the Docker image of your
application.

See the "Using curl" section for more details on why we use these options, and
"Possible Sticking Points" for some things that can go wrong.

#### With Kubernetes

Currently, only the hello-world example can be used with kubernetes. More
examples are planned.

Please ensure your cluster has kubeworker nodes before continuing.

Either configure your local installation of `kubectl` to talk to the kubernetes
API using [the instructions in the Kubernetes README](https://github.com/CiscoCloud/mantl/tree/master/roles/kubernetes#running-kubectl-remotely),
or ssh into one of your control nodes:
```bash
ssh <username>@<your-control-ip>
```
where `<username>` is generally one of `centos`, `root`, or `cloud-user`.

Then run
```bash
kubectl run hello-world --image=nginx
kubectl expose deployment hello-world --type=NodePort --port=8001 --target-port=80
```
This will expose your service on port 8001 on each of your kubeworker nodes.

### Finding your app

Note that some browsers may block Mantl's self-signed SSL certificate. If yours
does, please try another browser.

#### With Marathon + Mesos (CLI)

Run
```bash
curl -s \
     --cacert ssl/cacert.pem \
     -u "<user>:<pass>" \
     "https://<your-control-ip>/marathon/v2/apps/<your-app>" | python -m json.tool
```
You should get back something like:
```json
{"id":"/<your-app>","cmd":null,"args":null,"user":null,"env":{},"instances":2,"cpus":0.1,"mem":128.0,"disk":0.0,"executor":"","constraints":[],"uris":[],"storeUrls":[],"ports":[0],"requirePorts":false,"backoffFactor":1.15,"container":{"type":"DOCKER","volumes":[],"docker":{"image":"keithchambers/docker-hello-world","network":"BRIDGE","portMappings":[{"containerPort":80,"hostPort":0,"servicePort":0,"protocol":"tcp"}],"privileged":false,"parameters":[],"forcePullImage":false}},"healthChecks":[],"dependencies":[],"upgradeStrategy":{"minimumHealthCapacity":1.0,"maximumOverCapacity":1.0},"labels":{},"acceptedResourceRoles":null,"version":"2015-12-14T05:53:13.140Z","deployments":[{"id":"1b534972-53ee-4198-8860-ea0c48c3d7e9"}],"tasks":[],"tasksStaged":0,"tasksRunning":0,"tasksHealthy":0,"tasksUnhealthy":0,"backoffSeconds":1,"maxLaunchDelaySeconds":3600}
```
Look under "tasks". You should see a host, ID, and port. In your browser,
navigate to `http://<host>:<port>`.

#### With Marathon + Mesos (Web UI)

Open a browser window to the Marathon UI (see the section "IPs and URLs"). To
get information about an app click on the row in the UI. You should see a host,
ID, and port. In your browser, navigate to `http://<host>:<port>`.

![marathonui](./images/marathonui.png)

Click on the row for your application, and you'll see something like this:

![marathonui at application](./images/marathonapp.png)

Your app will have `default:<####>` under it where <####> is some port number.
In the picture above, these are ports 9061 and 25312.

If you click on the `worker-001:9061` it will open your browser to
`worker-001:9061` and get a `webpage is not avaiable` error. This is because you
don't have `worker-001` mapped to the node's IP address in your `/etc/hosts`
file. Rather than mess with that, you can just take the port information and add
it to the IP of your node. Open the browser to `<worker-ip>:9061` and you'll see:

![hello world application](./images/helloworld.png)

#### With Kubernetes

While logged into the remote host, or using your customized `kubectl` command,
run
```bash
kubectl describe svc <your-app>
```
Take a look at the field `NodePort`. You can reach your service by navigating
to `http://<your-kubeworker-ip>:<NodePort>`, where `<your-kubeworker-ip>` is the
IP address of one of your kubeworker nodes.

### Possible Sticking Points

#### curl

For more information on the options we use, see `man curl` and the "Using curl"
section further down.

If you forget to provide the `--cacert` option to `curl`, you may get a message
like this:

```
$ curl -X POST -H "Content-Type: application/json" -u "admin:hardpass" -d@"hello-world/hello-world.json" "https://192.168.100.101/marathon/v2/apps"
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
```

If you forgot to provide the `-X` or `-d` options to `curl`, you may get a
message like this:
```
$ curl -k -H "Content-Type: application/json" -u "admin:hardpass" -d@"hello-world/hello-world.json" "https://192.168.100.101/marathon/v2/apps"
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
```
If you remembered both, make sure the path you pass to `-d` exists.

If you forgot to provide the `-H application/json` option to `curl`, you may get
a message like this:
```
$ curl -k -X POST -u "admin:hardpass" -d@"hello-world/hello-world.json" "https://192.168.100.101/marathon/v2/apps"
curl: (6) Could not resolve host:  
{"message":"Unsupported Media Type"}
```

#### Marathon + Mesos

If your nodes don't have enough resources, the app will be stuck "deploying" in
the Marathon UI:

![marathon stuck](images/marathonstuck.png)

To investigate, go back to the Mantl UI and then navigate to the Mesos "Web UI".

![mesos stuck](images/mesosstuck.png)

If you don't see any resource offers (on the left hand side), you might have to
rebuild your Vagrant cluster with a different configuration. If you have the
resources on your computer, you can

1. Destroy your vagrant server. Go to the project root and type:
```bash
vagrant destroy
```

2. Create a `vagrant-config.yml` file in the root directory, and add

```
---
worker_memory: 3072
# For running on kubernetes,
# kubeworker_memory: 3072
```
as documented in the [Vagrant README](../vagrant/README.rst).

3. Run
```
vagrant up
```

4. Go through the example instructions again.

## Going Further

For more information on the commands we use in these examples, see the
documentation for [the Marathon REST API](https://mesosphere.github.io/marathon/docs/rest-api.html),
[kubectl](http://kubernetes.io/docs/user-guide/kubectl-overview/), and
[curl](https://curl.haxx.se/docs/manpage.html).

### Using curl

Here are some options we've used with `curl`, and why we used them:

 - `-X`: Use a HTTP verb other than the default GET.
 - `--cacert ssl/cacert.pem`: Use Mantl's certificate authority to validate your
 server's SSL/TLS certificate. Since Mantl has self-signed certificates,
 `curl`'s default bundle will reject them.
 - `-u <user>:<pass>`: Authenticate with Marathon using the provided username
 and password.
 - `-s`: From `man curl`: "Silent or quiet mode. Don't show progress meter or
 error messages. Makes Curl mute. It will still output the data you ask for,
 potentially even to the terminal/stdout unless you redirect it."
 - `-d @examples/hello-world/hello-world.json`: Send the data in that JSON file
 to Marathon

### Deleting Apps

#### Marathon

From this REST API, the call to destroy the application is:

```bash
curl -X DELETE \
     --cacert ssl/cacert.pem \
     -u "<user>:<pass>" \
     "https://<your-control-ip>/marathon/v2/apps/<your-app>"
```
Note the similarity with the API call for finding your application.

If the call is successful you will get something like:
```json
{"version":"2015-12-14T06:44:37.378Z","deploymentId":"e7680e8e-d073-4c57-9f64-e73d8b634398"}
```

Now you can check the status again, as per the previous section. It should give
you `{"message":"App '/hello-world' does not exist"}`.

#### Kubernetes

List your pods with
```bash
kubectl get pods
```
and destroy one with
```bash
kubectl delete pod <pod-id>
```

### MantlUI

Navigating to `https://<your-control-ip>` will take you to the Mantl UI, from
which you can view all other web UIs.

![mantlui](./images/mantlui.png)
