package element

type Metadata struct {
	Id      string   `json:"id"`
	Version string   `json:"version"`
	About   string   `json:"about"`
	Depends []string `json:"depends"`
	Cache   string   `json:"cache"`
}
