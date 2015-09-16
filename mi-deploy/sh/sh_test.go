package sh

import (
	"fmt"
	"math/rand"
	"os/exec"
	"path"
	"strings"
	"testing"
)

// how long do you want the tests to go? How many items do you want to test?
var inputs = 50
var files []string
var dirs []string

/********************** SHELL FUNCTIONS */

// TestMkdirP, TestTouch, and TestCp make more and more files to be put in files
// and dirs respectively, so that other tests can use them for their own
// purposes. They are all cleaned up by TestRmR.

func getRandomPath() string {
	return "test" + fmt.Sprint(rand.Int())
}

func TestMkdirP(t *testing.T) {
	basedir := "/tmp/sh_test.go/" // base for all other tests
	MkdirP(basedir)

	// TODO figure out how to close this
	dirsMade := make(chan string) // send back all the dirs you make
	innerLoopCounter := 5         // how many subdirs should be made?

	// make random directories
	for i := 0; i < inputs; i++ {
		go func(dirsMade chan string) {
			// nest 'em!
			currentBase := path.Join(basedir, getRandomPath())
			MkdirP(currentBase)
			dirsMade <- currentBase
			for x := 0; x < innerLoopCounter; x++ {
				p := path.Join(currentBase, getRandomPath())
				MkdirP(p)
				dirsMade <- p
			}
		}(dirsMade)
	}
	// consume channel values, add them to dirs, test their existence
	for i := 0; i < inputs*innerLoopCounter; i++ {
		d := <-dirsMade
		if !DirExists(d) {
			t.Error(fmt.Sprintf("Directory does not exist: %s", d))
		}
		dirs = append(dirs, d)
	}
}

func TestTouch(t *testing.T) {
	filesMade := make(chan string)
	// create random files, touch them, send their paths on the channel
	for i := 0; i < inputs; i++ {
		go func(filesMade chan string) {
			f := path.Join(dirs[rand.Intn(len(dirs))], getRandomPath())
			Touch(f)
			filesMade <- f
		}(filesMade)
	}
	// consume channel values, add them to files, test their existence
	for i := 0; i < inputs; i++ {
		f := <-filesMade
		if !FileExists(f) {
			t.Error(fmt.Sprintf("File does not exist: %s", f))
		}
		files = append(files, f)
	}
}

func TestCp(t *testing.T) {
	// no concurrency - "deadlock"
	for _, src := range files {
		dst := src + "-copy"
		Cp(src, dst)
		if FileExists(dst) {
			files = append(files, dst)
		} else {
			t.Errorf("Cp didn't create the expected file at %s", dst)
		}
	}
	for _, src := range dirs {
		dst := src + "-copy"
		Cp(src, dst)
		if DirExists(dst) {
			dirs = append(dirs, dst)
		} else {
			t.Errorf("Cp didn't create the expected dir at %s", dst)

		}
	}
}

func TestSetE(t *testing.T) {
	goodCommands := []*exec.Cmd{}
	for _, f := range files {
		goodCommands = append(goodCommands, exec.Command("ls", f))
	}
	for _, d := range dirs {
		goodCommands = append(goodCommands, exec.Command("ls", d))
	}
	others := []*exec.Cmd{
		exec.Command("sleep", ".0000001"),
		exec.Command("echo", "hey! ho!"),
	}
	// no concurrency here - "too many open files"
	for _, cmd := range append(goodCommands, others...) {
		_ = SetE(cmd)
	}
}

func TestPwdAndCd(t *testing.T) {
	// no concurrency - goroutines don't have their own working directories
	for _, dir := range dirs {
		Cd(dir)
		cmd := exec.Command("pwd")
		out, err := cmd.Output()
		expected := strings.TrimSpace(string(out))
		ExecError(cmd, expected, err)
		actual := Pwd()
		if actual != expected {
			msg := "Pwd didn't return the same value as `pwd`"
			msg += "\nExpected: " + expected
			msg += "\nActual: " + actual
			msg += "\nThis also might be an error in Cd."
			t.Error(msg)
		}
		expected2 := dir
		if actual != expected2 {
			msg := "Pwd didn't the name of the dir Cd'ed into"
			msg += "\nExpected: " + expected2
			msg += "\nActual: " + actual
			msg += "\nThis also might be an error in Cd."
			t.Error(msg)
		}
	}
}

func TestBasename(t *testing.T) {
	t.Parallel()
	inputs := []string{
		"/dev/null", "/proc/bus/", "/root", "/usr/local/bin",
		"/etc/skel/.bashrc", "/var/log/yum.log", "/sys/power/resume",
	}

	outputs := []string{}
	for _, input := range inputs {
		expected, err := exec.Command("basename", input).Output()
		if err != nil {
			t.Errorf("Error while executing `basename`: %s", err.Error())
		}
		outputs = append(outputs, strings.TrimSpace(string(expected)))
	}
	for i := range inputs {
		expected := outputs[i]
		actual := Basename(inputs[i])
		if actual != expected {
			msg := "Basename did not provide expcted output"
			msg += "\nExpected: " + expected
			msg += "\nActual: " + actual
			t.Error(msg)
		}
	}
}

func TestRmR(t *testing.T) {
	// no concurrency - "deadlock"
	// delete them
	for _, d := range dirs {
		if DirExists(d) {
			RmR(d)
		}
	}
	// check for dir existence
	for _, d := range dirs {
		if DirExists(d) {
			t.Errorf("Dir exists: %s", d)
		}
	}
	for _, f := range files {
		if FileExists(f) {
			t.Errorf("File exists: %s", f)
		}
	}
}

/********************** SHELL CONDITIONS */
