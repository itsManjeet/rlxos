package pkgupd

import (
	"fmt"
	"os"
	"rlxos/internal/element"

	"gopkg.in/yaml.v2"
)

type Pkgupd struct {
	Server  string `yaml:"server"`
	Channel string `yaml:"channel"`

	metadata []element.Metadata
}

const APPID = "pkgupd"

func New(configfile ...string) (*Pkgupd, error) {
	pkgupd := &Pkgupd{
		Server:  "http://repo.rlxos.dev",
		Channel: "stable",
	}
	if len(configfile) == 1 {
		data, err := os.ReadFile(configfile[0])
		if err != nil {
			return nil, fmt.Errorf("failed to read configuration file '%s': %v", configfile[0], err)
		}

		if err := yaml.Unmarshal(data, pkgupd); err != nil {
			return nil, fmt.Errorf("failed to read configuration file '%s': %v", configfile[0], err)
		}

	}

	return pkgupd, nil
}
