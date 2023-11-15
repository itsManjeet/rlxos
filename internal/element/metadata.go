package element

type Metadata struct {
	Id          string      `json:"id"`
	Version     string      `json:"version"`
	About       string      `json:"about"`
	Icon        string      `json:"icon"`
	Cache       string      `json:"cache"`
	Type        ElementType `json:"type"`
	Depends     []string    `json:"depends"`
	Integration string      `json:"integration"`
}

type ElementType string

const (
	ElementTypeLayer     ElementType = "layer"
	ElementTypeComponent ElementType = "component"
	ElementTypeApp       ElementType = "app"
)
