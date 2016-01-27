# Minecraft

You can run a simple (not persisted) Minecraft server on
Mantl pretty easily. Just run the following command from
the root of the project:

```
curl -k -X POST -H "Content-Type: application/json" "https://youruser:yourpass@192.168.242.55:8080/v2/apps" -d@"minecraft/minecraft.json"
```

Be aware that the Minecraft server needs at least 2GB of RAM to function
effectively. The DigitalOcean Terraform configuration is good to try this out
on, as it uses 4GB instances.  Or increase the memory allocated to vagrant by changing the vm memory value in the
Vagrantfile to at least 3.5G.

A [video demo](https://asteris.wistia.com/medias/nd77k59sk6) of this
configuration is available.

NOTE: he goes uses the service port and is then going to the proxy with that port. If you are
using vagrant you will want to go to the port that shows under the instance in the marathon ui
when you click on the application details.

Alternatively find the host and port in the tasks section of the following status check

    curl -k  "https://admin:hardpass@192.168.242.55:8080/v2/apps/minecraft" | python -m json.tool
