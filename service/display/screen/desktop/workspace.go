package desktop

import (
	"fmt"
	"image/color"
	"slices"
	"sync"

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/style"
	"rlxos.dev/pkg/graphics/widget"
	"rlxos.dev/service/display/surface"
)

type Workspace struct {
	widget.Base

	activeSurface *surface.Surface

	activeBorderColor   color.Color
	inactiveBorderColor color.Color

	mutex sync.Mutex
}

func (w *Workspace) Construct() {
	w.Layout = Tile
}

func (w *Workspace) OnStyleChange(s style.Style) {
	w.activeBorderColor = style.Lighten(s.Surface, 0.4)
	w.inactiveBorderColor = style.Lighten(s.Surface, 0.1)
}

func (w *Workspace) propagate(c string, payload any) error {
	if w.activeSurface == nil {
		if len(w.Children) == 0 {
			return nil
		}
		return fmt.Errorf("no active surface")
	}
	if err := w.activeSurface.Conn.Send(c, payload, nil); err != nil {
		return err
	}
	return nil
}

func (w *Workspace) surfaceFromConn(conn *connect.Connection) (*surface.Surface, bool) {
	idx := slices.IndexFunc(w.Children, func(w widget.Widget) bool {
		return w.(*surface.Surface).Conn == conn
	})
	if idx == -1 {
		return nil, false
	}
	return w.Children[idx].(*surface.Surface), true
}

func (w *Workspace) Raise(idx int) {
	w.mutex.Lock()
	defer w.mutex.Unlock()

	if w.activeSurface != nil {
		w.activeSurface.SetDirty(true)
	}

	if idx < 0 || idx > len(w.Children) {
		return
	}

	sf := w.Children[idx].(*surface.Surface)
	w.activeSurface = sf
	w.activeSurface.SetDirty(true)
}

func (w *Workspace) activeIndex() int {
	return slices.IndexFunc(w.Children, func(c widget.Widget) bool {
		return c.(*surface.Surface) == w.activeSurface
	})
}

func (w *Workspace) AddChild(c widget.Widget) {
	w.activeSurface = c.(*surface.Surface)
	w.Base.AddChild(c)
}

func (w *Workspace) RemoveChild(c widget.Widget) {
	if c == nil {
		return
	}

	w.Base.RemoveChild(c)
	if w.activeSurface == c.(*surface.Surface) {
		if len(w.Children) > 0 {
			w.activeSurface = w.Children[len(w.Children)-1].(*surface.Surface)
		} else {
			w.activeSurface = nil
		}
	}
}

func (w *Workspace) Draw(cv canvas.Canvas) {
	for _, c := range w.Children {
		borderColor := w.inactiveBorderColor
		if c == w.activeSurface {
			borderColor = w.activeBorderColor
		}

		if c.Dirty() {
			c.Draw(cv)
			graphics.Rect(cv, c.Bounds(), 0, borderColor)
			c.SetDirty(false)
		}
	}
}
