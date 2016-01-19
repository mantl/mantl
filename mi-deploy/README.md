## MI-Deploy

This tool automates the deployment of Mantl to all of its supported platforms.
It does so by creating a fresh, barebones clone of the repo from the specified
branch, generating or copying necessary authentication and terraform data, and
running Anisble and Terraform. It attempts to make this whole process more user
friendly and easy, while interactively catching errors and attempting fixes.

### Installation and Usage

#### Installation

This tool can be built with the `go` tool, with a simple
```bash
go get . && go build .
```

You can also download premade (but less frequently updated) binaries of
mi-deploy from our [Bintray][bintray], under the "Versions" tab.

Deployment requires your terraform files to be under a `tf-files/` directory. In
particular, your directory tree should look something like this:
```
$ tree .
.
├── deployments
│   └── ...
├── mi-deploy.go
├── mi-deploy           # compiled binary
├── README.md
├── ...
└── tf-files
    ├── terraform.yml   # optional, will be generated if not present
    ├── security.yml    # optional, will be generated if not present
    ├── account.json
    ├── aws.tf
    ├── digitalocean.tf
    ├── softlayer.tf
    ├── gce.tf
    └── openstack.tf
```

You only need a .tf file for whichever platform(s) you deploy to, and
security.yml, the ssl/ directory, and terraform.yml are optional. mi-deploy will
generate them if not present.

#### Usage

Once you have a binary, you can use the `--help` flag to show the help text for
any subcommand
```bash
$ ./mi-deploy --help
...
USAGE:
   mi-deploy [global options] command [command options] [arguments...]

VERSION:
   0.0.1-dev

COMMANDS:
   deploy   deploy a branch to a platform
   destroy  destroy the resources and files from a deployment
   help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --help, -h       show help
   --version, -v    print the version
```

Example usage:
```bash
$ ./mi-deploy deploy --platform aws --branch master
$ ./mi-deploy --verbosity=debug deploy -p vagrant -b fix/bug
$ ./mi-deploy destroy
$ ./mi-deploy destroy --filter "vagrant"
```

### Details

Calling deploy will create a new directory under `deployments/` which is named
by platform, branch, and timestamp. Your terraform data will then be copied
from `./tf-files/` into that clone, and Terraform and Ansible will be run
sequentially.

Upon encountering an error, mi-deploy attempts to provide useful options for
continuation. This often requires keyboard input. This script is designed to be
run manually, from a TTY (otherwise, it would be a simple bash script ;) ).

When using the `destroy` subcommand, the terraformed resources are destroyed
and the directory is deleted.

### Deploying From a Remote Machine

Using this program on a remote machine is easy! An example script is
provided in remote.sh.

### Roadmap

Hopefully, this program will pave the way for and implement some form of
automated building and testing of MI clusters. The big TODO item is automated
testing, to be integrated with something like Jenkins.

TODO:
 * Non-interactive mode, ability to retry on certain kinds of failure
 * Better test coverage
 * Automated testing
   - `curl` Consul health endpoints
   - Reboot hosts

### License

This is considered to be a part of Mantl, and is under the same licensing.

[bintray]: https://bintray.com/asteris/mantl-deploy/mantl-deploy/view
