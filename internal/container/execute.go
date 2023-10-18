package container

import (
	"fmt"
	"os"
	"os/exec"
	"rlxos/internal/color"
)

func (container *Container) execute(args ...string) error {
	fmt.Println(color.DarkGray, backend, args, color.Reset)

	cmd := exec.Command(backend, append([]string{"exec", "-i", container.name}, args...)...)
	cmd.Stdout = container.Logger
	cmd.Stdin = os.Stdin
	cmd.Stderr = container.Logger

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("command %v, failed with %v", args, err)
	}
	return nil
}

func (container *Container) ExecuteAt(dir string, args ...string) error {
	return container.execute(append([]string{"-w", dir}, args...)...)
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
