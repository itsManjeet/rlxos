package main

import (
	"fmt"
	"os"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/cloner"
)

func cloneCommand() *app.Command {
	parititonType := "ext4"
	bootloader := cloner.BOOTLOADER_GRUB
	isEfi := false
	if _, err := os.Stat("/sys/firmware/efi"); err == nil {
		isEfi = true
	}
	var efiPartition string
	return app.New("clone").
		About("Clone rlxos system to device").
		Init(func() (interface{}, error) {
			cloner := &cloner.Cloner{
				PartitionType: parititonType,
				Bootloader:    bootloader,
				IsEfi:         isEfi,
				EfiPartition:  efiPartition,
				PrettyName:    "RLXOS GNU/Linux",
			}

			return cloner, nil
		}).
		Flag(flag.New("partition-type").
			About("Specify partition type (default ext4)").
			Count(1).
			Handler(func(s []string) error {
				parititonType = s[0]
				return nil
			})).
		Flag(flag.New("bootloader").
			About("Specify Bootloader (default: grub) [grub,none]").
			Count(1).
			Handler(func(s []string) error {
				bootloader = cloner.Bootloader(s[0])
				return nil
			})).
		Flag(flag.New("uefi").
			About("Specify Uefi partition").
			Count(1).
			Handler(func(s []string) error {
				isEfi = true
				efiPartition = s[0]
				return nil
			})).
		Handler(func(c *app.Command, args []string, i interface{}) error {
			cl := i.(*cloner.Cloner)
			if len(args) != 2 {
				c.Help()
				return fmt.Errorf("no partition and disk image specified")
			}

			if err := cl.Clone(args[0], args[1]); err != nil {
				return fmt.Errorf("cloning failed %v", err)
			}
			return nil
		})
}
