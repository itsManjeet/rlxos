package config

type UpdateInfo struct {
	Version   int    `json:"version"`
	Url       string `json:"url"`
	Changelog string `json:"changelog"`
}
