package container

import (
	"fmt"
	"os"
	"rlxos/internal/color"
	"strings"
)

func (container *Container) dumpLogs(readCount int) {
	data, err := os.ReadFile(container.Logfile)
	if err != nil {
		fmt.Printf("failed to read log file %s, %v\n", container.Logfile, err)
		return
	}
	lines := strings.Split(string(data), "\n")
	count := len(lines)
	if count > readCount {
		lines = lines[len(lines)-readCount : len(lines)-1]
	}
	fmt.Println(color.Red + strings.Join(lines, "\n") + color.Reset)
}
