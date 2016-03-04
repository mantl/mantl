# Jupyter 
It is rather simple to deploy Jupyter on MANTL. There are some official Docker images that you can use for this purpose (https://github.com/jupyter/docker-stacks). For this example we use the jupyter/minimal-notebook.


We wrapped the Marathon submit REST call in a small script: `deploy.sh`. You can use it to deploy Jupyter on your MANTL cluster.

```bash
./deploy.sh
```

It takes a while to download the Jupyter image from DockerHub (up to 15 minutes), so please be patient the first time you deploy it. If everything went fine, you should be able to figure out the front end URL of your Jupyter deployment from the Traefik UI. Alternatively, if you deployed MANTL locally, you can even access Jupyter using the back end URL available in the Marathon UI.

**Warning** Due to an issue (https://github.com/CiscoCloud/mantl/issues/1142), the Jupyter working directory won't be writable on GlusterFS. To fix this we need to ssh into a node and change the ownership of it. 

```bash
sudo chown centos /mnt/container-volumes/jupyter/
```
