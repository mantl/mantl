# Minecraft

You can run a simple (not persistent) Minecraft server on Mantl pretty easily.
Just run the following command from the root of the project:

```
curl -k -u "youruser:yourpass" -X POST -H "Content-Type: application/json" "https://192.168.100.101/marathon/v2/apps" -d@"minecraft/minecraft.json"
```

Be aware that the Minecraft server needs at least 2GB of RAM to function
effectively. The DigitalOcean Terraform configuration is good to try this out
on, as it uses 4GB instances.  Or increase the memory allocated to your Vagrant
worker(s) as documented in the Vagrant README.

A [video demo](https://asteris.wistia.com/medias/nd77k59sk6) of this
configuration is available.

NOTE: The video uses the service port and is then going to the proxy with that
port. If you are using vagrant you will want to go to the port that shows under
the instance in the Marathon UI when you click on the application details.

Alternatively, you can find the host and port in the tasks section of the
following status check

    curl -k -u "youruser:yourpass" "https://@192.168.100.101/marathon/v2/apps/minecraft" | python -m json.tool
