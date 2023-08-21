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

	Reset = "\033[0m"
)

const (
	FOREGROUND int = 30
	BACKGROUND int = 40
	DARKCOLOR  int = 100
)

var NoColor = false

func titled(color string, mesg string, s ...interface{}) {
	prefix := time.Now().Format("2006/01/02 3:4:5 PM")
	suffix := "\n"
	if !NoColor {
		prefix = fmt.Sprintf("%s[%s%s%s%s]%s%s", color, Reset, Bold, prefix, color, Reset, Bold)
		suffix = Reset + suffix
	}

	fmt.Printf(prefix+" "+mesg+suffix, s...)

}

func Process(mesg string, s ...interface{}) {
	titled(Green, mesg, s...)
}

func Error(mesg string, s ...interface{}) {
	titled(Red, Red+"ERROR: "+Reset+mesg, s...)
}

func Warn(mesg string, s ...interface{}) {
	titled(Orange, Orange+"Warn: "+Reset+mesg, s...)
}
