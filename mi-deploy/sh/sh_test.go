package sh

import (
	"fmt"
	"math/rand"
	"os/exec"
	"path"
	"testing"
)

// how long do you want the tests to go? How many items do you want to test?
var inputs = 50
var files []string
var dirs []string

/********************** SHELL FUNCTIONS */

// mkdir, touch come first so we can have a reliable set of files to work with

func getRandomPath() string {
	return "test" + fmt.Sprint(rand.Int())
}

func TestMkdirP(t *testing.T) {
	basedir := "/tmp/sh_test.go/"
	MkdirP(basedir)

	// make random directories
	for i := 0; i < inputs; i++ {
		// nest 'em!
		currentBase := path.Join(basedir, getRandomPath())
		MkdirP(currentBase)
		dirs = append(dirs, currentBase)
		for x := 0; x < 5; x++ {
			p := path.Join(currentBase, getRandomPath())
			MkdirP(p)
			dirs = append(dirs, p)
		}
	}

	// test that they all got made
	for _, dir := range dirs {
		if !DirExists(dir) {
			t.Error(fmt.Sprintf("Directory does not exist: %s", dir))
		}
	}
}

func TestTouch(t *testing.T) {
	// create random files, add them to the array, and touch them
	for i := 0; i < inputs; i++ {
		f := path.Join(dirs[rand.Intn(len(dirs))], getRandomPath())
		files = append(files, f)
		Touch(files[len(files)-1])
	}
	for _, f := range files {
		if !FileExists(f) {
			t.Error(fmt.Sprintf("File does not exist: %s", f))
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
	for _, cmd := range append(goodCommands, others...) {
		_ = SetE(cmd)
	}
}

func TestRmR(t *testing.T) {
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
