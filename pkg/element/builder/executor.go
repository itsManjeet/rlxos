package builder

import (
	"bufio"
	"fmt"
	"log"
	"math/rand"
	"os"
	"os/exec"
	"rlxos/pkg/color"
	"time"
)

type Container struct {
	name string
}

const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const backend = "docker"

func randStringBytes(n int) string {
	rand.Seed(time.Now().UnixNano())
	b := make([]byte, n)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}

func CreateContainer(image string, environ []string, mounts map[string]string) (*Container, error) {
	c := &Container{
		name: randStringBytes(10),
	}
	args := []string{
		"run", "--privileged", "-dt", "--name", c.name,
		"--net=host",
		"--hostname=rlxos",
		"-e", "HOME=/",
		"-e", "PS1='(rlxos) \\W \\$'",
	}

	for _, e := range environ {
		args = append(args, "-e", e)
	}
	for dest, src := range mounts {
		args = append(args, "-v", src+":"+dest)
	}
	args = append(args, image, "tail", "-f", "/dev/null")
	fmt.Println(color.DarkGray, backend, args, color.Reset)
	if data, err := exec.Command(backend, args...).CombinedOutput(); err != nil {
		return nil, fmt.Errorf("%v, %s", string(data), err)
	}
	for _, i := range []string{"/etc/hosts", "/etc/hostname", "/etc/resolv.conf"} {
		exec.Command(backend, "exec", "-i", c.name, "umount", i).CombinedOutput()
	}

	// TODO: Remove this temporary fix
	exec.Command(backend, "exec", "-i", c.name, "mkdir", "-p", "/tmp").CombinedOutput()

	return c, nil
}

func (c *Container) RescueShell() {
	log.Println("COMMAND FAILED, Entering rescue shell")
	e := exec.Command(backend, "exec", "-t", "-e", "HOME=/", "-e", "PS1='(rlxos) \\W \\$'", "-i", c.name, "sh")
	e.Stdout = os.Stdout
	e.Stdin = os.Stdin
	e.Stderr = os.Stderr

	e.Run()
}

func (c *Container) Run(lw *bufio.Writer, cmd []string, dir string, environ []string) error {
	args := []string{
		"exec",
	}
	for _, e := range environ {
		args = append(args, "-e", e)
	}
	args = append(args, "-w", dir, "-i", c.name)
	args = append(args, cmd...)
	fmt.Fprintln(lw, "COMMAND:", args)

	fmt.Println(color.DarkGray, backend, args, color.Reset)
	e := exec.Command(backend, args...)
	e.Stdout = lw
	e.Stderr = lw
	e.Stdin = os.Stdin
	err := e.Run()

	lw.Flush()

	if err != nil {
		return fmt.Errorf("command %v failed with %v", args, err)
	}
	return nil
}

func (c *Container) Delete() error {
	if data, err := exec.Command(backend, "rm", "-f", c.name).CombinedOutput(); err != nil {
		return fmt.Errorf("%v, %s", string(data), err)
	}
	return nil
}
