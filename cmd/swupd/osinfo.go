package main

import (
	"fmt"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/osinfo"
	"strings"
)

func osinfoCommand() *app.Command {
	osReleaseFile := "/etc/os-release"
	return app.New("osinfo").
		About("osinfo show os information").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Flag(flag.New("release-file").
			Count(1).
			About("Specify custom os-release file").
			Handler(func(s []string) error {
				osReleaseFile = s[0]
				return nil
			})).
		Init(func() (interface{}, error) {
			o, err := osinfo.Open(osReleaseFile)
			if err != nil {
				return nil, err
			}
			return o, nil
		}).
		Handler(func(c *app.Command, s []string, b interface{}) error {
			o := b.(osinfo.OsInfo)
			if len(s) == 0 {
				maxKeySize := 0
				for key := range o {
					if len(key) > maxKeySize {
						maxKeySize = len(key) + 5
					}
				}
				for key, value := range o {
					fmt.Printf("%s%*.s : %s\n", key, maxKeySize-len(key), " ", value)
				}
			}
			for _, key := range s {
				fmt.Println(o[strings.ToUpper(key)])
			}

			return nil
		})
}
