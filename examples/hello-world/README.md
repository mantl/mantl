Example
---

`vagrant up`

After Vagrant has had time to spin up the instance.

1. Open a browser window to the [Marathon UI](http://127.0.0.1:8080/).
2. Run `examples/hello-world/launch.sh -c examples/hello-world/hello-world.json -m 127.0.0.1` to start the _hello-world_ example. You will see the Marathon UI update with the new application as two instances are deployed.
3. To get information about an app click on the row in the UI. Or, from the command line run `curl -s "http://127.0.0.1:8080/v2/apps/hello-world" | python json.tool`.
4. To remove the application use the _Destroy App_ button on the details pop-up in the UI. Or, from the command line run `curl -s -X DELETE "http://127.0.0.1:8080/v2/apps/hello-world" | python json.tool`.

See the [Marathon REST API Documentation](https://mesosphere.github.io/marathon/docs/rest-api.html) for more information on the options available.
