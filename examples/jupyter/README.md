# Jupyter

We'll often use the more general instructions from
[the README for the examples folder](../README.md). When following these
instructions, you should replace `<your-app>` with `jupyter`.

We're using the Docker image jupyter/minimal-notebook from
[the Jupyter team](https://github.com/jupyter/docker-stacks).

## Step 0: Create your cluster

See [the README for the examples folder](../README.md), under "Creating a Mantl
Cluster".

## Step 1: Figure out the IP address of your control node

See [the README for the examples folder](../README.md), under "IPs and URLs".

## Step 2: Launch your app

See [the README for the examples folder](../README.md), under "Launching Your App".

**Warning** Due to a known issue
(https://github.com/CiscoCloud/mantl/issues/1142), the Jupyter working directory
won't be writable on GlusterFS. We can use ansible to fix this:
```bash
ansible --become all -a 'chown centos /mnt/container-volumes/jupyter'
```

## Step 3: View your app

See [the README for the examples folder](../README.md), under "Finding your app".
