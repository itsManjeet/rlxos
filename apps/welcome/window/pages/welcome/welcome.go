package welcome

import (
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	. "rlxos/apps/welcome/locale"
)

type Page struct {
	gtk.Box
}

func NewWelcomePage() *Page {
	p := &Page{Box: *gtk.NewBox(gtk.OrientationVertical, 0)}

	p.setupUI()

	return p
}

func (p *Page) setupUI() {
	icon := gtk.NewImageFromIconName("start-here-symbolic")
	icon.SetPixelSize(128)
	p.Append(icon)

	p.SetVAlign(gtk.AlignCenter)
	p.SetHAlign(gtk.AlignCenter)
	p.SetMarginBottom(120)

	title := gtk.NewLabel(T("Welcome to RLXOS"))
	title.AddCSSClass("heading")
	p.Append(title)

	subtitle := gtk.NewLabel(T("Follow to step-by-step guide to know more about rlxos"))
	p.Append(subtitle)

}

func (p *Page) CanGoBack() bool { return true }

func (p *Page) CanGoForward() bool { return true }

func (p *Page) Title() string { return T("Welcome") }
