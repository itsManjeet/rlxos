package config

import "rlxos/pkg/element"

type UpdateInfo struct {
	Version    int                `json:"version"`
	Cache      string             `json:"cache"`
	Url        string             `json:"url"`
	Changelog  string             `json:"changelog"`
	Components []element.Metadata `json:"components"`
}
