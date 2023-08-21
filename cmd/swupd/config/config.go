package config

import (
	"os"

	"gopkg.in/yaml.v2"
)

type Config struct {
	Server  string `yaml:"server"`
	Channel string `yaml:"channel"`
}

func Load(configfile string) (*Config, error) {
	data, err := os.ReadFile(configfile)
	if err != nil {
		return nil, err
	}
	var c Config
	if err := yaml.Unmarshal(data, &c); err != nil {
		return nil, err
	}

	return &c, nil
}
