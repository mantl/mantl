# Kong

Kong is an "Open-source, Microservice & API Management Layer built on top of
NGINX". It is a great example of a real world microservices based application
that can be run with ease on Mantl. To do so, just fill in the $ip, $username,
and $password variables in the deploy.sh script and run it from this directory.
The script is extensively commented, and walks you through the steps necessary
to deploy Kong.

After deploying, you can log into the Marathon UI on any of your control nodes
at `<control-ip>/marathon/#apps/%2Fkong`, see what port Kong is accessible on,
and ping it from any of your other nodes:

```bash
curl kong.service.consul:<port-number>
```
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
