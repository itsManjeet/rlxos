package osinfo

import (
	"fmt"
	"os/exec"
	"strings"
)

func Arch() (string, error) {
	output, err := exec.Command("uname", "-m").CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("%s, %v", string(output), err)
	}
	return strings.Trim(string(output), " \n"), nil
}
