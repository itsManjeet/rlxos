package container

import (
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"rlxos/internal/color"
	"time"
)

// Container provides an isolated environment to build components
type Container struct {
	Image string

	Environ []string
	Binds   map[string]string
	Logfile string

	HostRoot string

	name string
}

const backend = "docker"

func randStringBytes(n int) string {
	const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	rand.Seed(time.Now().UnixNano())
	b := make([]byte, n)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}

func (container *Container) New() error {
	if container.name != "" {
		return fmt.Errorf("container already initialized with name %s", container.name)
	}
	container.name = "rlxos-" + randStringBytes(10)

	args := []string{
		"run", "--privileged", "-dt", "--name", container.name,
		"--net=host",
		"--hostname=rlxos",
		"--env", "HOME=/",
		"--env", "TERM=linux",
		"--env", "PS1='(rlxos) \\W \\$'",
		"--env", "PATH=/usr/bin",
		"--env", "NOCONFIGURE=1",
	}

	for _, env := range container.Environ {
		args = append(args, "--env", env)
	}

	for dest, source := range container.Binds {
		args = append(args, "--volume", fmt.Sprintf("%s:%s", source, dest))
	}

	args = append(args, container.Image, "sleep", "infinity")
	fmt.Println(color.DarkGray, backend, args, color.Reset)

	if output, err := exec.Command(backend, args...).CombinedOutput(); err != nil {
		return fmt.Errorf("failed to start container: %s %v", string(output), err)
	}

	// TODO: Temporary Fixes
	container.Execute("mkdir", "-p", "/usr/local/include")

	return nil
}

func (cntr *Container) Delete() error {
	cntr.Script(fmt.Sprintf("rm -rf %s/* %s/*", cntr.ContainerPath(BUILD_ROOT), cntr.ContainerPath(INSTALL_ROOT)))
	if data, err := exec.Command(backend, "rm", "-f", cntr.name).CombinedOutput(); err != nil {
		return fmt.Errorf("%v, %s", string(data), err)
	}
	os.RemoveAll(cntr.HostRoot)
	return nil
}
