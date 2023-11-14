package pkgupd

import "rlxos/internal/element"

type Pkgupd struct {
	Server  string `yaml:"server"`
	Channel string `yaml:"channel"`

	metadata []element.Metadata
}

const APPID = "pkgupd"

func New() (*Pkgupd, error) {
	return &Pkgupd{
		Server:  "http://repo.rlxos.dev",
		Channel: "experimental",
	}, nil
}
