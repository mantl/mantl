# Minecraft

We'll often use the more general instructions from
[the README for the examples folder](../README.md). When following these
instructions, you should replace `<your-app>` with `minecraft`.

This runs a non-persisting Minecraft server on your Mantl cluster. A
[video demo](https://asteris.wistia.com/medias/nd77k59sk6) of this configuration
is available. The video uses the service port and is then going to the proxy
with that port. If you are using Vagrant you will want to go to the port that
shows under the instance in the Marathon UI when you click on the application
details.

## Step 0: Create your cluster

See [the README for the examples folder](../README.md), under "Creating a Mantl
Cluster".

## Step 1: Figure out the IP address of your control node

See [the README for the examples folder](../README.md), under "IPs and URLs".

## Step 2: Launch your app

See [the README for the examples folder](../README.md), under "Launching Your App".

Be aware that the Minecraft server needs at least 2GB of RAM to function
effectively. The DigitalOcean Terraform configuration is good to try this out
on, as it uses 4GB instances. See
[the README for the examples folder](../README.md), under "Launching Your App".
under "Possible Sticking Points" for increasing the RAM in your Vagrant config.

## Step 3: View your app

See [the README for the examples folder](../README.md), under "Finding your app".
