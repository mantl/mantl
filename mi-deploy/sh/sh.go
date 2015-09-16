/*
Package sh implements a couple of native golang functions that act just like
shell utilities. It is useful in situations where you might think of using
plain old BASH or sh, but want a more structured approach, with a type system
as an extra.
*/
package sh

import (
	log "github.com/Sirupsen/logrus"
	"io/ioutil"
	"os"
	"os/exec"
	"strings"
)

// best effort to implement Cd("-") like `cd -`
var lastWorkDir = Pwd()

/********************** SHELL FUNCTIONS */
// SetE is like `set -e`, it expects a command to succeed and exits with an
// error message if it doesn't.
func SetE(cmd *exec.Cmd) (output string) {
	log.Debugf("Executing %s", cmd.Args)
	out, err := cmd.CombinedOutput()
	outStr := string(out)
	if err != nil {
		ExecError(cmd, outStr, err)
	}
	return outStr
}

// Pwd is like `pwd`, it returns the current working directory as a string, or
// exits with an error message if unsucessful.
func Pwd() (wd string) {
	wd, err := os.Getwd()
	if err != nil {
		log.WithFields(log.Fields{
			"error": err.Error(),
		}).Fatal("Couldn't get working dir")
	}
	return wd
}

// Basename returns whatever comes after the trailing slash in a filepath.
func Basename(path string) (name string) {
	log.Debugf("sh.Basename -> %s", path)
	// basename ignores trailing slashes and never includes them in output
	path = strings.TrimSuffix(path, "/")
	// handle cases made explicit by the manpage
	// http://man7.org/linux/man-pages/man3/basename.3.html
	idex := strings.LastIndex(path, "/")
	if path == "/" {
		return "/"
	} else if idex == -1 { // path has no slashes
		return path
	}
	// if it's not a special case, return the path from last slash onwards
	return path[idex+1:]
}

// Cp is like `cp -a`, it copies everything located at the given path.
func Cp(src, dst string) {
	log.Debugf("sh.Cp %s -> %s", src, dst)
	cmd := exec.Command("cp", "-a", src, dst)
	out, err := cmd.CombinedOutput()
	ExecError(cmd, string(out), err)
}

// Cd works like `cd`, it changes the current working directory, or exits with
// an error message.
func Cd(dst string) {
	log.Debugf("sh.Cd -> %s", dst)
	var err error
	if dst == "-" {
		err = os.Chdir(dst)
	} else {
		err = os.Chdir(dst)
	}
	lastWorkDir = dst
	if err != nil {
		log.WithFields(log.Fields{
			"pwd":   Pwd(),
			"dst":   dst,
			"error": err.Error(),
		}).Fatal("Error while changing directories")
	}
}

// RmR works like `rm -r`, it recursively removes everything located at the
// given path, or exits with an error message.
func RmR(path string) {
	log.Debugf("sh.RmR -> %s", path)
	err := os.RemoveAll(path)
	if err != nil {
		log.WithFields(log.Fields{
			"target": path,
			"pwd":    Pwd(),
			"error":  err.Error(),
		}).Fatal("Couldn't recursively remove dir")
	}
}

// Touch simply creates a new, empty file with mode 0644. It will wipe out other
// files if they exist, and log an error if it can't write to the file specified.
func Touch(path string) {
	log.Debugf("sh.Touch -> %s", path)
	err := ioutil.WriteFile(path, []byte{}, 0644)
	CouldntWriteError(path, err)
}

// MkdirP makes a directory at path, creating all parent directories if
// necessary and possible.
func MkdirP(path string) {
	err := os.MkdirAll(path, 0755)
	CouldntWriteError(path, err)
}

/********************** SHELL CONDITIONS */
// SymlinkExists returns whether or not the given path represents a symlink.
func SymlinkExists(path string) bool {
	_, err := os.Readlink(path)
	return err == nil
}

// FileExists returns whether or not the given path represents a plain file.
func FileExists(path string) bool {
	if SymlinkExists(path) {
		return false
	}
	fileInfo, _ := os.Stat(path)
	return (fileInfo != nil && fileInfo.Mode().IsRegular())
}

// DirExists returns whether or not the given path represents a plain directory.
func DirExists(path string) bool {
	if SymlinkExists(path) {
		return false
	}
	fileInfo, _ := os.Stat(path)
	return (fileInfo != nil && fileInfo.Mode().IsDir())
}

/********************** ERROR FUNCTIONS */
// PathError is an abstraction of CouldntReadError and CouldntWriteError.
func PathError(path string, err error, read bool) {
	// is it a read or write error?
	readOrWrite := "write"
	if read {
		readOrWrite = "read"
	}

	if err != nil {
		log.WithFields(log.Fields{
			"path":  path,
			"error": err.Error(),
		}).Fatal("Couldn't " + readOrWrite + " file/dir")
	}
}

// CouldntWriteError logs.Fatal an error relating to writing a file.
func CouldntWriteError(path string, err error) {
	PathError(path, err, false)
}

// CouldntReadError logs.Fatal an error related to reading a file.
func CouldntReadError(path string, err error) {
	PathError(path, err, true)
}

// ExecError logs.Fatal with a useful message for errors that occur when
// using os/exec to run commands.
func ExecError(cmd *exec.Cmd, out string, err error) {
	if err != nil {
		msg := "Failed to execute command"
		if strings.Contains(out, "permission denied") {
			msg = "Permission denied when running command"
		} else if strings.Contains(err.Error(), "not found in $PATH") {
			msg = "Couldn't find executable when running command"
		}
		log.WithFields(log.Fields{
			"command": cmd.Args,
			"path":    cmd.Path,
			"pwd":     Pwd(),
			"output":  out,
			"error":   err.Error(),
		}).Fatal(msg)
	}
}
