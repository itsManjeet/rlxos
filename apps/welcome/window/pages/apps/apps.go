package apps

import (
	_ "embed"
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

func NewAppsPage() *Page {
	p := &Page{Box: *gtk.NewBox(gtk.OrientationVertical, 0)}
	p.setupUI()
	return p
}

func (p *Page) setupUI() {
	p.SetVAlign(gtk.AlignCenter)
	p.SetHAlign(gtk.AlignCenter)

	icon := gtk.NewImageFromIconName("applications-all-symbolic")
	icon.SetPixelSize(64)
	icon.SetMarginBottom(12)
	p.Append(icon)

	heading := gtk.NewLabel(T("Get your favorite apps here"))
	heading.AddCSSClass("heading")
	p.Append(heading)

	subheading := gtk.NewLabel(T("Browse and install your favorite apps effortlessly.\nExplore new tools, utilities, and games—all available directly in the Software Center."))
	subheading.SetJustify(gtk.JustifyCenter)
	subheading.SetMarginBottom(24)
	p.Append(subheading)

	button := gtk.NewButtonWithLabel(T("Browse apps"))
	button.ConnectClicked(func() {
		button.SetSensitive(false)
		button.SetLabel(T("Starting..."))

		cmd := exec.Command(config.SoftwareCenter)
		if err := cmd.Start(); err != nil {
			log.Println("failed to start software center", err)
		} else {
			go func() {
				if err := cmd.Wait(); err != nil {
					log.Println("failed to wait for software center", err)
				}
				glib.IdleAdd(func() bool {
					button.SetSensitive(true)
					button.SetLabel(T("Browse apps"))
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

func (p *Page) Title() string { return T("Applications") }
