Example
---

**Important** -- Bootstrap security configuration by running `./security-setup`
once to generate `security.yml`. Customize as necessary for environment before
starting the VM with Vagrant.

For the examples below use the credentials from the `marathon_http_credentials`
key, found in `security.yml`, in place of `<user>` and `<pass>`.

First, run `vagrant up`. While Vagrant is spinning up the VMs, check out the
Vagrant README to figure out the IP addresses it will assign. If you're using
the default configuration, you'll have one control node at "192.168.100.101" and
one worker at "192.168.100.201".

1. Open a browser window to the [Marathon UI](https://192.168.100.101/marathon/)
(vagrant-control-ip:8080).
2. Run the following command to start the _hello-world_ example:
```
examples/hello-world/launch.sh -c examples/hello-world/hello-world.json -m 192.168.100.101 -u <user> -p <pass>
```
You will see the Marathon UI update with the new application as two instances
are deployed.
3. To get information about an app click on the row in the UI, or from the
command line, run
```bash
curl -k -s -u "<user>:<pass>" "https://192.168.100.101/marathon/v2/apps/hello-world" | python -m json.tool
```
4. To see the app running, look at the output of the above command, under tasks.
You should see a host, id, and port. In your browser go to the
http://<host>:<port>. Some browsers may block the self-signed SSL certificate.
If this is the case, try another browswer.
5. To remove the application use the _Destroy App_ button on the details pop-up
in the UI. Or, from the command line run
```bash
curl -ksu "<user>:<pass>" -X DELETE "https://192.168.100.101/marathon/v2/apps/hello-world" | python -m json.tool
```

See the [Marathon REST API Documentation](https://mesosphere.github.io/marathon/docs/rest-api.html) for more information on the options available.
