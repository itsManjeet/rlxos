package color

import (
	"fmt"
	"time"
)

const (
	Black     string = "\033[1;30m"
	Red       string = "\033[1;31m"
	Green     string = "\033[1;32m"
	Orange    string = "\033[1;33m"
	Blue      string = "\033[1;34m"
	Magenta   string = "\033[1;35m"
	Cyan      string = "\033[1;36m"
	LightGray string = "\033[1;37m"
	Bold      string = "\033[1m"

	DarkGray string = "\033[1;30m"

	Reset = "\033[0m"
)

const (
	FOREGROUND int = 30
	BACKGROUND int = 40
	DARKCOLOR  int = 100
)

var NoColor = false

func Titled(color string, title string, format string, s ...interface{}) {
	prefix := time.Now().Format("2006/01/02 3:4:5 PM")
	fmt.Printf("%s[%s%s%s%s]%s%s %s %s%s", color, Reset, Bold, prefix, color, Reset, color, title, Reset, Bold)
	fmt.Printf(format, s...)
	fmt.Println(Reset)
}

func Process(format string, s ...interface{}) {
	Titled(Green, "PROCESS", format, s...)
}

func Error(format string, s ...interface{}) {
	Titled(Red, "ERROR", format, s...)
}

func Warn(format string, s ...interface{}) {
	Titled(Orange, "WARN", format, s...)
}
