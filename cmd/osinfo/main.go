package main

import (
	"fmt"
	"log"
	"os"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/osinfo"
)

var (
	OS_RELEASE = "/etc/os-release"
)

func main() {

	if err := app.New("osinfo").
		About("osinfo show os information").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Flag(flag.New("release-file").
			Count(1).
			About("Specify custom os-release file").
			Handler(func(s []string) error {
				OS_RELEASE = s[0]
				return nil
			})).
		Init(func() (interface{}, error) {
			o, err := osinfo.Open(OS_RELEASE)
			if err != nil {
				return nil, err
			}
			return o, nil
		}).
		Handler(func(c *app.Command, s []string, b interface{}) error {
			o := b.(*osinfo.OsInfo)
			for key, value := range *o {
				fmt.Println(key, ":", value)
			}
			return nil
		}).
		Run(os.Args); err != nil {

		log.Println(err)
		os.Exit(1)
	}
}
