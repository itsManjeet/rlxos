package locale

import (
	_ "embed"
	"rlxos/pkg/localize"
)

//go:embed hi.yaml
var hi []byte

func init() {
	localize.Add("hi", hi)
}

func T(s string) string {
	return localize.Translate(s)
}
