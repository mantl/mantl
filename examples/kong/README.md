# Kong

[Kong](https://getkong.org) is an "Open-source, Microservice & API Management
Layer built on top of NGINX". It is a great example of a real world
microservices based application that can be run with ease on Mantl. To do so,
first fill in the $ip, $username, and $password variables in the deploy.sh
script. Make sure that you are in the `examples/kong` directory and then run
deploy.sh. The script is extensively commented, and walks you through the steps
necessary to deploy Kong.

After deploying, you can log into the Marathon UI on any of your control nodes
at `<control-ip>/marathon/#apps/%2Fkong`, see what port Kong is accessible on,
and ping it from any of your other nodes:

```bash
curl kong.service.consul:<port-number>
```

Adjust the `.consul` domain if you customized it when you built your cluster.
You should get a response that looks like this:

```json
{
	"version": "0.5.4",
	"lua_version": "LuaJIT 2.1.0-alpha",
	"tagline": "Welcome to Kong",
	"hostname": "5611a8c0dc6c",
	"plugins": {
		"enabled_in_cluster": {},
		"available_on_server": ["ssl", ...]
	}
}
```

By default, Kong will also be load-balanced by
[Traefik](https://traefik.github.io) on edge nodes. If you do not want this, add
`"traefik.enable": "false"` to the "labels" section in the Marathon json
(kong.json in this directory). Assuming you have DNS setup in your cluster, you
will be able to reach the Kong proxy layer at `kong.<traefik_marathon_domain>`
