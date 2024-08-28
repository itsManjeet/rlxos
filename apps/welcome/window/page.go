package window

import "github.com/diamondburned/gotk4/pkg/gtk/v4"

type IPage interface {
	gtk.Widgetter

	CanGoBack() bool
	CanGoForward() bool

	Title() string
}
