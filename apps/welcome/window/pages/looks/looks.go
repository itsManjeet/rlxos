package looks

import (
	"fmt"
	"log"
	"os/exec"
	"rlxos/apps/welcome/config"
	. "rlxos/apps/welcome/locale"

	"github.com/diamondburned/gotk4/pkg/gtk/v4"
)

type Page struct {
	gtk.Box

	slider *gtk.Scale
}

func NewLooksPage() *Page {
	p := &Page{Box: *gtk.NewBox(gtk.OrientationVertical, 0)}
	p.setupUI()
	return p
}

func (p *Page) setupUI() {
	p.SetVAlign(gtk.AlignCenter)
	p.SetMarginBottom(128)

	themeLabel := gtk.NewLabel(T("Choose Your Theme"))
	themeLabel.AddCSSClass("subheading")
	themeLabel.SetMarginBottom(12)
	p.Append(themeLabel)

	btnBox := gtk.NewBox(gtk.OrientationHorizontal, 24)
	btnBox.SetHAlign(gtk.AlignCenter)
	p.Append(btnBox)

	darkThemeImage := gtk.NewImageFromIconName("dark-mode-symbolic")
	darkThemeImage.SetPixelSize(64)

	darkThemeBtn := gtk.NewButton()
	darkThemeBtn.SetChild(darkThemeImage)
	darkThemeBtn.ConnectClicked(func() { p.SwitchToDarkTheme() })
	darkThemeBtn.AddCSSClass("circular")
	btnBox.Append(darkThemeBtn)

	lightThemeImage := gtk.NewImageFromIconName("brightness-display-symbolic")
	lightThemeImage.SetPixelSize(64)

	lightThemeBtn := gtk.NewButton()
	lightThemeBtn.SetChild(lightThemeImage)
	lightThemeBtn.ConnectClicked(func() { p.SwitchToLightTheme() })
	lightThemeBtn.AddCSSClass("circular")
	btnBox.Append(lightThemeBtn)

	dpiLabel := gtk.NewLabel(T("Adjust Display Scale"))
	dpiLabel.AddCSSClass("subheading")
	dpiLabel.SetMarginBottom(12)
	dpiLabel.SetMarginTop(54)
	p.Append(dpiLabel)

	p.slider = gtk.NewScaleWithRange(gtk.OrientationHorizontal, 0, 100, 10)
	for i := 0; i <= 100; i += 10 {
		p.slider.AddMark(float64(i), gtk.PosTop, "")
	}
	p.slider.ConnectValueChanged(func() {
		p.UpdateScaling()
	})
	p.slider.SetMarginStart(40)
	p.slider.SetMarginEnd(40)
	p.slider.SetValue(20)
	p.Append(p.slider)
}

func (p *Page) UpdateScaling() {
	scale := p.slider.Value()
	p.setConfig("xsettings", "/Xft/DPI", fmt.Sprintf("%d", int(scale+90)))
}

func (p *Page) SwitchToDarkTheme() {
	p.setGsettings("org.gnome.desktop.interface", "gtk-theme", config.GtkDarkTheme)
	p.setConfig("xsettings", "/Net/ThemeName", config.GtkDarkTheme)

	p.setGsettings("org.gnome.desktop.interface", "icon-theme", config.IconDarkTheme)
	p.setConfig("xsettings", "/Net/IconThemeName", config.IconDarkTheme)
}

func (p *Page) SwitchToLightTheme() {
	p.setGsettings("org.gnome.desktop.interface", "gtk-theme", config.GtkLightTheme)
	p.setConfig("xsettings", "/Net/ThemeName", config.GtkLightTheme)

	p.setGsettings("org.gnome.desktop.interface", "icon-theme", config.IconLightTheme)
	p.setConfig("xsettings", "/Net/IconThemeName", config.IconLightTheme)
}

func (p *Page) setConfig(channel, property, value string) {
	if output, err := exec.Command("xfconf-query", "-c", channel, "-p", property, "-s", value).CombinedOutput(); err != nil {
		log.Printf("Failed to set config %s: %s %s", property, string(output), err)
	}
}

func (p *Page) setGsettings(channel property, value string) {
	if output, err := exec.Command("gsettings", "set", channel, property, value).CombinedOutput(); err != nil {
		log.Printf("Failed to set config %s: %s %s", property, string(output), err)
	}
}

func (p *Page) CanGoBack() bool { return true }

func (p *Page) CanGoForward() bool { return true }

func (p *Page) Title() string { return T("Customize Your Look") }
