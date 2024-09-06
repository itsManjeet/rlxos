package style

import (
	_ "embed"
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	"log"
	"strings"
)

//go:embed global.css
var global string

func Provider() *gtk.CSSProvider {
	provider := gtk.NewCSSProvider()
	provider.ConnectParsingError(func(section *gtk.CSSSection, err error) {
		loc := section.StartLocation()
		lines := strings.Split(global, "\n")
		log.Printf("CSS Error (%v) at line: %q", err, lines[loc.Lines()])
	})
	provider.LoadFromString(global)
	return provider
}
