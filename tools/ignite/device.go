package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Device struct {
	Name        string   `json:"name"`
	Description string   `json:"description"`
	Arch        string   `json:"arch"`
	Emulation   []string `json:"emulation"`
}

func (d Device) ArchAlias() string {
	if a, ok := archAliases[d.Arch]; ok {
		return a
	}
	return d.Arch
}

func (d Device) TargetTriple() string {
	return fmt.Sprintf("%s-linux-musl", d.ArchAlias())
}

func LoadDeviceConfig(d string) error {
	data, err := os.ReadFile(d)
	if err != nil {
		return err
	}

	if err := json.Unmarshal(data, &device); err != nil {
		return err
	}
	return nil
}
