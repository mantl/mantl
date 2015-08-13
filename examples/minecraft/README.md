# Minecraft

You can run a simple (not persisted) Minecraft server on
microservices-infrastructure pretty easily. Just run the following command from
the root of the project:

```
curl -X PUT -H "Content-Type: application/json" -d @examples/minecraft/minecraft.json http://youruser:yourpass@your-mi-domain.com:8080/v2/apps/minecraft
```

Be aware that the Minecraft server needs at least 2GB of RAM to function
effectively. The DigitalOcean Terraform configuration is good to try this out
on, as it uses 4GB instances.

A [video demo](https://asteris.wistia.com/medias/nd77k59sk6) of this
configuration is available.
