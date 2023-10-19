package container

import (
	"fmt"
	"os"
	"os/exec"
	"path"
	"rlxos/internal/color"
)

func (container *Container) executeAt(dir string, args ...string) error {
	file, err := os.OpenFile(container.Logfile, os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0640)
	if err != nil {
		return fmt.Errorf("failed to open log file %s: %v", container.Logfile, err)
	}
	defer file.Close()
	args = append([]string{"exec", "-w", dir, "-i", container.name}, args...)
	fmt.Println(color.DarkGray, backend, args, color.Reset)

	cmd := exec.Command(backend, args...)
	cmd.Stdout = file
	cmd.Stdin = os.Stdin
	cmd.Stderr = file

	return cmd.Run()
}

func (container *Container) ExecuteAt(dir string, args ...string) error {
	return container.executeAt(dir, args...)
}

func (container *Container) Execute(args ...string) error {
	return container.ExecuteAt("/", args...)
}

func (container *Container) ScriptAt(dir string, code string) error {
	return container.ExecuteAt(dir, "sh", "-ec", code)
}

func (container *Container) Script(code string) error {
	return container.ScriptAt("/", code)
}

func (container *Container) Mkdir(dirs ...string) error {
	return container.Execute("mkdir", "-p", path.Join(dirs...))
}
