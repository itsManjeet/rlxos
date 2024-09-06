package support

import (
	"github.com/diamondburned/gotk4/pkg/glib/v2"
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	"log"
	"os/exec"
	"rlxos/apps/welcome/config"
	. "rlxos/apps/welcome/locale"
)

type Page struct {
	gtk.Box
}

func NewSupportPage() *Page {
	p := &Page{Box: *gtk.NewBox(gtk.OrientationVertical, 0)}
	p.setupUI()
	return p
}

func (p *Page) setupUI() {
	p.SetVAlign(gtk.AlignCenter)
	p.SetHAlign(gtk.AlignCenter)

	icon := gtk.NewImageFromIconName("help-symbolic")
	icon.SetPixelSize(64)
	icon.SetMarginBottom(12)
	p.Append(icon)

	heading := gtk.NewLabel(T("Help & Support"))
	heading.AddCSSClass("heading")
	p.Append(heading)

	subheading := gtk.NewLabel(T("Need assistance? Explore our documentation\nor connect with the community for answers to your questions."))
	subheading.SetMarginBottom(24)
	subheading.SetJustify(gtk.JustifyCenter)
	p.Append(subheading)

	button := gtk.NewButtonWithLabel(T("Open Support"))
	button.ConnectClicked(func() {
		button.SetLabel(T("Starting..."))
		button.SetSensitive(false)
		cmd := exec.Command("exo-open", config.SupportUrl)
		if err := cmd.Start(); err != nil {
			log.Println("failed to load support url", err)
		} else {
			go func() {
				if err := cmd.Wait(); err != nil {
					log.Println("failed to load support url", err)
				}

				glib.IdleAdd(func() bool {
					button.SetSensitive(true)
					button.SetLabel(T("Open Support"))
					return true
				})
			}()
		}
	})
	button.SetHAlign(gtk.AlignCenter)
	button.SetVAlign(gtk.AlignCenter)
	p.Append(button)
}

func (p *Page) CanGoBack() bool { return true }

func (p *Page) CanGoForward() bool { return true }

func (p *Page) Title() string { return T("Help and Support") }
