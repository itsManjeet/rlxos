package window

import (
	"github.com/diamondburned/gotk4/pkg/gtk/v4"
	"os"
	"rlxos/apps/welcome/config"
	. "rlxos/apps/welcome/locale"
	"rlxos/apps/welcome/window/pages/apps"
	"rlxos/apps/welcome/window/pages/finish"
	"rlxos/apps/welcome/window/pages/looks"
	"rlxos/apps/welcome/window/pages/support"
	"rlxos/apps/welcome/window/pages/welcome"
)

type Window struct {
	gtk.Window
	stack   *gtk.Stack
	backBtn *gtk.Button
	nextBtn *gtk.Button

	pages []IPage
	idx   int
}

func NewWindow() *Window {
	win := &Window{Window: *gtk.NewWindow()}

	win.setupUI()
	win.setupPages()
	win.updatePage()

	return win
}

func (win *Window) setupPages() {
	win.pages = append(win.pages,
		welcome.NewWelcomePage(),
		looks.NewLooksPage(),
		apps.NewAppsPage(),
		support.NewSupportPage(),
		finish.NewFinishPage(),
	)
	for _, page := range win.pages {
		win.stack.AddChild(page)
	}

	win.SetChild(win.stack)
}

func (win *Window) setupUI() {
	win.SetDefaultSize(800, 600)

	headerBar := gtk.NewHeaderBar()
	headerBar.SetShowTitleButtons(false)
	win.SetTitlebar(headerBar)

	win.backBtn = gtk.NewButtonWithLabel(T("Back"))
	win.backBtn.ConnectClicked(func() {
		win.idx--
		win.updatePage()
	})
	headerBar.PackStart(win.backBtn)

	win.nextBtn = gtk.NewButtonWithLabel(T("Next"))
	win.nextBtn.AddCSSClass("suggested-action")
	win.nextBtn.ConnectClicked(func() {
		if win.idx == len(win.pages)-1 {
			_ = os.WriteFile(config.DoneFile, []byte(""), 0644)
			win.Application().Quit()
			return
		}
		win.idx++
		win.updatePage()
	})
	headerBar.PackEnd(win.nextBtn)

	win.stack = gtk.NewStack()
	win.stack.SetTransitionDuration(200)
	win.stack.SetTransitionType(gtk.StackTransitionTypeSlideLeftRight)
}

func (win *Window) updatePage() {
	win.stack.SetVisibleChild(win.pages[win.idx])
	win.backBtn.SetSensitive(win.idx > 0 && win.pages[win.idx].CanGoBack())
	win.nextBtn.SetSensitive(win.idx < len(win.pages) && win.pages[win.idx].CanGoForward())
	if win.idx == len(win.pages)-1 {
		win.nextBtn.SetLabel(T("Finish"))
	} else {
		win.nextBtn.SetLabel(T("Next"))
	}

	win.SetTitle(win.pages[win.idx].Title())
}
