package config

import (
	"os"
	"path"
)

const (
	GtkDarkTheme  = "Orchis-Dark"
	GtkLightTheme = "Orchis-Light"

	IconDarkTheme  = "Tela-dark"
	IconLightTheme = "Tela-light"

	SoftwareCenter = "gnome-software"

	SupportUrl = "https://github.com/itsManjeet/rlxos/discussions"
)

var (
	DoneFile = path.Join(os.Getenv("HOME"), ".welcome-done")
)
