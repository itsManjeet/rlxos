package main

import (
	"github.com/diamondburned/gotk4/pkg/gdk/v4"
	"github.com/diamondburned/gotk4/pkg/gio/v2"
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	"os"
	"rlxos/apps/welcome/config"
	"rlxos/apps/welcome/window"
	"rlxos/apps/welcome/window/style"
)

func main() {
	app := gtk.NewApplication("dev.rlxos.Welcome", gio.ApplicationFlagsNone)

	if _, err := os.Stat(config.DoneFile); err == nil && os.Getenv("WELCOME_TOUR_AS_APP") == "" {
		os.Exit(0)
	}

	app.ConnectStartup(func() {
		gtk.StyleContextAddProviderForDisplay(
			gdk.DisplayGetDefault(), style.Provider(),
			gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
	})

	app.ConnectActivate(func() {
		win := app.ActiveWindow()
		if win == nil {
			win = &window.NewWindow().Window
			app.AddWindow(win)
		}
		win.Present()
	})

	os.Exit(app.Run(os.Args))
}
