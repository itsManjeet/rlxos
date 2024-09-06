package finish

import (
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	. "rlxos/apps/welcome/locale"
)

type Page struct {
	gtk.Box
}

func NewFinishPage() *Page {
	p := &Page{Box: *gtk.NewBox(gtk.OrientationVertical, 0)}
	p.setupUI()
	return p
}

func (p *Page) setupUI() {
	p.SetHAlign(gtk.AlignCenter)
	p.SetVAlign(gtk.AlignCenter)
	p.SetMarginBottom(36)

	icon := gtk.NewImageFromIconName("ticktick-tray")
	icon.SetPixelSize(64)
	icon.SetMarginBottom(12)
	p.Append(icon)

	heading := gtk.NewLabel(T("You're All Set!"))
	heading.AddCSSClass("heading")
	p.Append(heading)

	subheading := gtk.NewLabel(T("Your system is ready. Dive in\nand start exploring or fine-tune your settings further."))
	subheading.SetMarginBottom(24)
	subheading.SetJustify(gtk.JustifyCenter)
	p.Append(subheading)

}

func (p *Page) CanGoBack() bool { return true }

func (p *Page) CanGoForward() bool { return true }

func (p *Page) Title() string { return T("Finalize") }
