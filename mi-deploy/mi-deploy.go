// package main deploys Microservices-Infrastructure to a variety of platforms
// with ease!
package main

// This package attempts extensive comments, but make sure to look at the
// log statements for further information about what the code does!

import (
	"./prompt" // validated, typed command line input
	"./sh"     // sh-like functions
	"bufio"    // filtering Ansible output, currently unused
	"bytes"    // fileContains
	"fmt"
	log "github.com/Sirupsen/logrus" // structured logging
	"github.com/codegangsta/cli"     // opt parsing
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"strings"
	"time" // directory naming
)

/********************** CONFIGURABLE VARIABLES */
// this is a default, it can be overridden with the -u option
var repoURL = "http://github.com/CiscoCloud/microservices-infrastructure"
var pythonBinary = "/usr/bin/python2"

/********************** GLOBAL VARIABLES */
var timestamp = time.Now().Format("Mon-15:04:05")
var wd = sh.Pwd()
var terraformDir = path.Join(wd, "tf-files/")

const Name = "mi-deploy"
const Version = "v0.1.0"

// these are configured in the App action/subcommand "deploy", as they are on
// a per-deployment basis
var deploymentDir string
var repoDir string
var tfstateDir string

/********************** GENERAL FUNCTIONS */
// StringPredicate is a function that filters a list of strings
type StringPredicate func(str string) bool

// AnySatisfies checks to see whether any string in a given slice satisfies the
// provided StringPredicate.
func AnySatisfies(pred StringPredicate, slice []string) bool {
	for _, sliceString := range slice {
		if pred(sliceString) {
			return true
		}
	}
	return false
}

// StrIn checks to see if a given string is in a slice of strings.
func StrIn(str string, slice []string) bool {
	pred := func(strx string) bool { return (strx == str) }
	return AnySatisfies(pred, slice)
}

// RemovePathChars removes a bunch of characters from a string that might be
// considered inappropriate for paths, like "/", and replaces them with the
// more benign "-".
func RemovePathChars(str string) string {
	toReturn := str
	disallowed := []string{
		"/", "?", "<", ">", `\`, ":", "*", "|", `"`, "^", "%", " ",
	}
	for _, char := range disallowed {
		toReturn = strings.Replace(toReturn, char, "-", -1)
	}
	return toReturn
}

// FileContains checks to see whether or not the file at path contains the given
// data.
func FileContains(path string, subslice []byte) bool {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		sh.CouldntReadError(path, err)
	}
	return bytes.Contains(data, subslice)
}

// FileToBytes reads a file and fails if there is an error
func FileToBytes(path string) []byte {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		log.WithFields(log.Fields{
			"path": path,
		}).Fatal(err.Error())
	}
	return data
}

// FileToLines reads in a file at a path, fails on errors, splits it into lines,
// and returns those lines as byte slices
func FileToLines(path string) [][]byte {
	return bytes.Split(FileToBytes(path), []byte("\n"))
}

// ExecuteWithOutput executes a command. If logrus's verbosity level is set to
// debug, it will continuously output the command's output while it waits.
func ExecuteWithOutput(cmd *exec.Cmd) (outStr string, err error) {
	// connect to stdout and stderr for filtering purposes
	errPipe, err := cmd.StderrPipe()
	if err != nil {
		log.WithFields(log.Fields{
			"cmd": cmd.Args,
		}).Fatal("Couldn't connect to command's stderr")
	}
	outPipe, err := cmd.StdoutPipe()
	if err != nil {
		log.WithFields(log.Fields{
			"cmd": cmd.Args,
		}).Fatal("Couldn't connect to command's stdout")
	}
	_ = bufio.NewReader(errPipe)
	outReader := bufio.NewReader(outPipe)

	// start the command and filter the output
	if err = cmd.Start(); err != nil {
		return "", err
	}
	outScanner := bufio.NewScanner(outReader)
	for outScanner.Scan() {
		outStr += outScanner.Text() + "\n"
		if log.GetLevel() == log.DebugLevel {
			fmt.Println(outScanner.Text())
		}
	}
	err = cmd.Wait()
	return outStr, err
}

/********************** SPECIFIC FUNCTIONS */
// getBranch fetches the git repo at urlstr to the folder dst and checks out
// branch. It uses a specific set of options for minimal hassle and bandwidth,
// and avoids cloning if the repo/dir is already present.
func getBranch(urlstr string, branch string, dst string) {
	log.Debugf("Getting branch %s", branch)
	if sh.DirExists(dst) {
		log.Infof("Folder exists, skipping cloning %s", dst)
		log.Infof("Checking out %s", branch)
		if oldPwd := sh.Pwd(); !(oldPwd == dst) {
			sh.Cd(dst)
			sh.SetE(exec.Command("git", "checkout", branch))
			sh.Cd(oldPwd)
		} else {
			sh.SetE(exec.Command("git", "checkout", branch))
		}
	} else {
		log.Infof("Cloning into %s", dst)
		cloneCmd := []string{
			// don't verify the ssl certificate (I've run into trouble with it)
			"-c", "http.sslVerify=false",
			"clone", urlstr, dst,
			// only clone this branch, with two commits of history
			"--branch=" + branch, "--single-branch",
			"--depth", "2",
		}
		sh.SetE(exec.Command("git", cloneCmd...))
	}
	log.Debugf("Done getting branch %s", branch)
}

// runTerraform gets, plans, and applies, and prompts the user for input if
// something doesn't work.
func runTerraform(path string) {
	oldPwd := sh.Pwd()
	sh.Cd(path)
	log.Debug("Checking to see if terraform can be executed properly")
	sh.SetE(exec.Command("terraform", "--version"))
	cmds := []*exec.Cmd{
		exec.Command("terraform", "get"),
		exec.Command("terraform", "plan"),
		exec.Command("terraform", "apply"),
	}
	log.Info("Terraforming...")
	for _, cmd := range cmds {
		// if this isn't nil at the end of the condition, ansible failed
		outStr, err := ExecuteWithOutput(cmd)
		if err != nil {
			log.Warnf("Terraform failed during %s", cmd.Args)
			done := false
			for !done {
				msg := "Looks like terraform failed. What would you like to do?"
				options := []string{
					"Show output and prompt again",
					"Retry (get, plan, apply)",
					"Try provisioning anyway",
					"Destroy and quit",
					"Quit",
				}
				switch prompt.PromptChoice(msg, options) {
				case "Show output and prompt again":
					fmt.Println(outStr)
					done = false
				case "Retry (get, plan, apply)":
					runTerraform(path)
					done = true
				case "Destroy and quit":
					terraformDestroy(path)
					done = true
					os.Exit(0)
				case "Try provisioning anyway":
				default:
					log.Info("Quitting...")
					os.Exit(0)
				}
			}
		}
	}
	sh.Cd(oldPwd)
	log.Debug("Done terraforming")
}

func printAdminPassword() {
	path := path.Join(repoDir, "security.yml")
	if _, err := os.Stat(path); err != nil {
		log.WithFields(log.Fields{
			"path": path,
		}).Fatal("Couldn't read security.yml when trying to print password")
	}
	for _, line := range FileToLines(path) {
		if bytes.Contains(line, []byte("nginx_admin_password:")) {
			words := bytes.Split(line, []byte(" "))
			log.Info("Your admin password is " + string(words[len(words)-1]))
			return
		}
	}
	log.WithFields(log.Fields{
		"path": path,
	}).Fatal("Couldn't find your admin password in security.yml")
}

// waitForHosts runs the ansible playbook `playbooks/wait-for-hosts.yml`,
// which waits for the hosts to respond before moving on with the provisioning
func waitForHosts(path string) {
	oldPwd := sh.Pwd()
	sh.Cd(path)
	log.Debug("Ensuring ansible-playbook can be executed properly")
	sh.SetE(exec.Command("ansible-playbook", "--version"))
	pathToPlaybook := "./playbooks/wait-for-hosts.yml"
	ansibleCommand := []string{
		"-i", "plugins/inventory/terraform.py",
		"-e", "ansible_python_interpreter=" + strings.TrimSpace(pythonBinary),
		"-e", "@security.yml",
		pathToPlaybook,
	}
	cmd := exec.Command("ansible-playbook", ansibleCommand...)
	log.Info("Waiting for SSH access to hosts...")
	outStr, err := ExecuteWithOutput(cmd)
	if err != nil {
		log.WithFields(log.Fields{
			"command": cmd.Args,
			"output":  outStr,
			"error":   err.Error(),
		}).Fatalf("Couldn't execute playbook %s", pathToPlaybook)
	}
	sh.Cd(oldPwd)
}

// runAnsible runs the ansible playbook with a few extra options, and allows
// for a bunch of different options upon failure.
func runAnsible(path string, opts []string) {
	oldPwd := sh.Pwd()
	sh.Cd(path)
	log.Debug("Ensuring ansible-playbook can be executed properly")
	sh.SetE(exec.Command("ansible-playbook", "--version"))
	ansibleCommand := []string{
		"-i", "plugins/inventory/terraform.py",
		"-e", "ansible_python_interpreter=" + strings.TrimSpace(pythonBinary),
		"-e", "@security.yml",
		"./terraform.yml",
	}
	cmd := exec.Command("ansible-playbook", append(ansibleCommand, opts...)...)
	log.Info("Provisioning...")
	outStr, err := ExecuteWithOutput(cmd)
	if err != nil {
		log.Warnf("Ansible command failed: %s", cmd.Args)
		done := false
		for !done {
			msg := "Looks like Ansible failed. What would you like to do?"
			options := []string{
				"Show output and prompt again",
				"Retry",
				"Retry with -vvvv",
				"Destroy, Terraform, and retry",
				"Destroy, Terraform, and retry with -vvvv",
				"Destroy and quit",
				"Quit",
			}
			// woo self documenting code!
			switch prompt.PromptChoice(msg, options) {
			case "Show output and prompt again":
				fmt.Println(outStr)
				done = false
			case "Retry":
				runAnsible(path, []string{})
				done = true
			case "Retry with -vvvv":
				runAnsible(path, []string{"-vvvv"})
				done = true
			case "Destroy, Terraform, and retry":
				terraformDestroy(path)
				runTerraform(path)
				runAnsible(path, []string{})
				done = true
			case "Destroy, Terraform, and retry with -vvvv":
				terraformDestroy(path)
				runTerraform(path)
				runAnsible(path, []string{"-vvvv"})
				done = true
			case "Destroy and quit":
				terraformDestroy(path)
				done = true
			default:
				log.Info("Quitting...")
				os.Exit(0)
			}
		}
	}
	sh.Cd(oldPwd)
	log.Debug("Done running Ansible")
}

func copyNecessaryFiles(platform string) {
	// copy in terraform and auth files
	tfFile := path.Join(terraformDir, platform+".tf")
	toCopy := []string{tfFile}
	// gce needs another auth file
	if platform == "gce" {
		toCopy = append(toCopy, path.Join(terraformDir, "account.json"))
	}
	log.Debug("Copying in authentication/terraform files")
	for _, record := range toCopy {
		sh.Cp(record, repoDir)
	}
	// Copy terrafom.yml in, or generate a new one from sample
	if sh.FileExists(path.Join(terraformDir, "terraform.yml")) {
		log.Debug("Copying terraform.yml from " + terraformDir)
		src := path.Join(terraformDir, "terraform.yml")
		sh.Cp(src, path.Join(repoDir, "terraform.yml"))
	} else {
		log.Debug("Generating terraform.yml from sample")
		src := path.Join(repoDir, "terraform.sample.yml")
		sh.Cp(src, path.Join(repoDir, "terraform.yml"))
	}
	// Copy ssl/, security.yml in or generate new ones
	if sh.FileExists(path.Join(terraformDir, "security.yml")) {
		log.Debug("Copying security.yml, ssl/ from " + terraformDir)
		src := path.Join(terraformDir, "security.yml")
		sh.Cp(src, path.Join(repoDir, "security.yml"))
		src = path.Join(terraformDir, "ssl/")
		sh.Cp(src, path.Join(repoDir, "ssl/"))
	} else {
		log.Debug("Running security-setup")
		sh.SetE(exec.Command("./security-setup"))
		printAdminPassword()
	}
}

// deployToCloud runs all the necessary steps for getting MI up and running on
// one of the supported clouds
func deployToCloud(platform string, branch string) {
	getBranch(repoURL, branch, repoDir)
	oldPwd := sh.Pwd()
	sh.Cd(repoDir)
	copyNecessaryFiles(platform)
	runTerraform(repoDir)
	waitForHosts(repoDir)
	runAnsible(repoDir, []string{})
	sh.Cd(oldPwd)
	log.Debug("Done deploying!")
}

// deployToVagrant runs all the necessary steps to deploy an MI instance to
// its Vagrant box.
func deployToVagrant(branch string) {
	getBranch(repoURL, branch, repoDir)
	oldPwd := sh.Pwd()
	sh.Cd(repoDir)
	log.Info("Bringing Vagrant box up, please wait.")
	sh.SetE(exec.Command("vagrant", "up"))
	sh.Cd(oldPwd)
}

// promptDestroy prompts the user asking which deployment they want to get rid
// of and calls destroyDeployment appropriately.
func promptDestroy(filter string) {
	log.Debug("Beginning destruction prompt process")
	oldPwd := sh.Pwd()

	// find all active deployments
	sh.Cd("deployments/")
	deploymentInfos, err := ioutil.ReadDir(".")
	sh.CouldntReadError(deploymentDir, err)
	toList := []string{}
	deployments := []string{}
	for _, deploymentInfo := range deploymentInfos {
		deployments = append(deployments, deploymentInfo.Name())
	}
	log.Debugf("Found these deployments:\n%s", deployments)
	// filter the deployments if a regex was provided with --filter
	if filter != "" {
		re, err := regexp.Compile(filter)
		if err != nil {
			log.Fatal("Couldn't parse filter regexp")
		}
		for _, deployment := range deployments {
			if re.MatchString(deployment) {
				toList = append(toList, deployment)
			}
		}
	} else {
		toList = deployments
	}
	if len(toList) < 1 {
		if filter == "" {
			log.Info("No deployments found!")
		} else {
			log.Info("No deployments found that matched that filter.")
		}
		os.Exit(0)
	}

	// prompt the user and ask which one they would like to destroy
	log.Debugf("Prompting user...")
	msg := "Which deployment would you like to eliminate?"
	// TODO catch error here
	toRemove, _ := filepath.Abs(prompt.PromptChoice(msg, toList))
	log.Debugf("User chose to remove %s", toRemove)
	// kill it!
	destroyDeployment(toRemove)
	sh.Cd(oldPwd)
}

// terraformDestroy is a simple wrapper around $(terraform destroy) that makes
// it require no input and logs some useful messages in some cases.
func terraformDestroy(path string) {
	oldPwd := sh.Pwd()
	sh.Cd(path)
	log.Info("Destroying terraformed resources...")
	if !sh.FileExists("terraform.tfstate") {
		log.WithFields(log.Fields{
			"pwd": sh.Pwd(),
		}).Warn("No terraform.tfstate file to use in destruction!")
	}
	cmd := exec.Command("terraform", "destroy", "-force")
	outStr, err := ExecuteWithOutput(cmd)
	if err != nil {
		log.WithFields(log.Fields{
			"output":  outStr,
			"command": cmd.Args,
		}).Warn("Terraform destroy may have failed")
	}
	sh.Cd(oldPwd)
	log.Debug("Done destroying terraformed resources.")
}

// destroyDeployment shuts down a deployments instances, and removes all its
// data. It expects the (absolute) parent path, e.g. the one above the repo dir.
func destroyDeployment(toRemove string) {
	log.Debug("Destroying deployment %s", toRemove)
	oldPwd := sh.Pwd()
	toRemoveRepo := path.Join(toRemove, sh.Basename(repoURL))
	sh.Cd(toRemoveRepo)

	log.Debugf("Actually destroying resources now")
	cloudRe := regexp.MustCompile(`(gce|aws|digitalocean|openstack|softlayer)`)
	if cloudRe.MatchString(toRemove) {
		log.Debug("Destroying terraformed resources in %s", toRemoveRepo)
		terraformDestroy(toRemoveRepo)
	} else {
		log.Debug("Destroying vagrant box in %s", toRemoveRepo)
		sh.SetE(exec.Command("vagrant", "destroy", "-f"))
	}

	sh.Cd(oldPwd)
	log.Debugf("Removing leftovers in %s", toRemove)
	sh.RmR(toRemove)
	log.Debug("Finished destruction process")
}

// setVerbosity both validates and notifies Logrus of the command-line
// specified verbosity level
func setVerbosity(verbosity string) {
	log.Debugf("Validating user-input verbosity level: %s", verbosity)
	lvls := []string{"debug", "info", "warn", "fatal", "panic"}
	if !StrIn(verbosity, lvls) {
		log.WithFields(log.Fields{
			"specified": verbosity,
		}).Fatal("Invalid verbosity option passed")
	}
	log.Debugf("Setting Logrus verbosity level")
	switch verbosity {
	case "debug":
		log.SetLevel(log.DebugLevel)
	case "info":
		log.SetLevel(log.InfoLevel)
	case "warn":
		log.SetLevel(log.WarnLevel)
	case "fatal":
		log.SetLevel(log.FatalLevel)
	case "panic":
		log.SetLevel(log.PanicLevel)
	}
}

// getApp returns a cli app object to be used for parsing command line options,
// as well as most of the logic of the program itself. It is a large method,
// but doesn't lend itself to breaking down.
// TODO app action doesn't seem to be run every time and set the verbosity.
// CLI might be able to use a PR.
func getApp() (app *cli.App) {
	// global app variables (name, version, etc)
	app = cli.NewApp()
	app.Name = "mi-deploy"
	app.Usage = "Deploy MI to various public clouds"
	app.Version = "0.0.1-dev"
	app.Author = "Langston Barrett"
	app.Email = "langston@aster.is"
	lvls := []string{"debug", "info", "warn", "fatal", "panic"}
	lvlsStr := strings.Join(lvls, " | ")
	platforms := []string{"aws", "digitalocean", "gce", "openstack", "softlayer", "vagrant"}
	platformsStr := strings.Join(platforms, " | ")

	// these are command line subcommands like $(git status). They have their
	// own flags, but more importantly, actions that are executed when the
	// subcommand is used.
	app.Commands = []cli.Command{
		{
			Name:  "deploy",
			Usage: "deploy a branch to a platform",
			Flags: []cli.Flag{
				cli.StringFlag{
					Name:  "platform, p",
					Value: "",
					Usage: "Deploy to this platform. One of:\n\t" + platformsStr,
				},
				cli.StringFlag{
					Name:  "branch, b",
					Value: "master",
					Usage: "Deploy this branch (optional, default is master)",
				},
				cli.StringFlag{
					Name:  "url, u",
					Value: repoURL,
					Usage: "Clone from this remote URL (optional)",
				},
				cli.StringFlag{
					Name:  "verbosity",
					Value: "info",
					Usage: lvlsStr,
				},
			},

			// the logic of deploying a branch
			Action: func(c *cli.Context) {
				log.Debug("Running subcommand deploy")
				// set verbosity
				setVerbosity(c.String("verbosity"))
				repoURL = c.String("url")
				platform := c.String("platform")
				branch := c.String("branch")
				// set global variables
				suffix := RemovePathChars(branch)
				suffix += "-" + platform + "-" + timestamp + "/"
				deploymentDir = path.Join(wd, "deployments/", suffix)
				repoDir = path.Join(deploymentDir, sh.Basename(repoURL))

				// deploy
				platforms := []string{
					"aws", "digitalocean", "gce", "openstack", "softlayer", "vagrant",
				}
				if platform == "vagrant" {
					deployToVagrant(branch)
				} else if StrIn(platform, platforms) {
					deployToCloud(platform, branch)
				} else {
					log.WithFields(log.Fields{
						"specified": platform,
					}).Fatal("Invalid platform option passed")
				}
			},
		},
		{
			Name:  "destroy",
			Usage: "destroy the resources and files from a deployment",
			Flags: []cli.Flag{
				cli.StringFlag{
					Name:  "filter, f",
					Value: "",
					Usage: "Only list deployments that match this regex",
				},
				cli.StringFlag{
					Name:  "verbosity",
					Value: "info",
					Usage: lvlsStr,
				},
			},
			Action: func(c *cli.Context) {
				log.Debug("Running subcommand destroy")
				// set verbosity
				setVerbosity(c.String("verbosity"))

				promptDestroy(c.String("filter"))
			},
		},
	}
	return app
}

func main() {
	log.Debug("Welcome!")
	getApp().Run(os.Args)
	log.Debug("Exiting...")
	os.Exit(0)
}
