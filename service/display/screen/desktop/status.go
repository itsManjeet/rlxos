package desktop

import (
	"image/color"
	"time"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/alignment"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/layout"
	"rlxos.dev/pkg/graphics/style"
	"rlxos.dev/pkg/graphics/widget"
)

type Status struct {
	widget.Base

	BackgroundColor color.Color
	BorderColor     color.Color

	start  widget.Label
	center widget.Label
	end    widget.Label

	tick time.Time
}

func (s *Status) Construct() {
	s.Layout = layout.Horizontal

	s.start.VerticalAlignment = alignment.Middle
	s.AddChild(&s.start)

	s.center.HorizontalAlignment = alignment.Middle
	s.center.VerticalAlignment = alignment.Middle
	s.AddChild(&s.center)

	s.end.HorizontalAlignment = alignment.End
	s.end.VerticalAlignment = alignment.Middle
	s.AddChild(&s.end)

	s.tick = time.Now()

	s.Base.Construct()
}

func (s *Status) pushNotification(msg string) {
	s.center.Text = msg
	s.center.SetDirty(true)
}

func (s *Status) Dirty() bool {
	if time.Since(s.tick) > time.Second {
		s.tick = time.Now()
		s.end.Text = s.tick.Format("3:04 PM Mon, 2 Jan")
		s.SetDirty(true)
		return true
	}
	return false
}

func (s *Status) Draw(cv canvas.Canvas) {
	graphics.FillRect(cv, s.Bounds(), 0, s.BackgroundColor)
	s.Base.Draw(cv)
	graphics.Rect(cv, s.Bounds(), 0, s.BorderColor)
}

func (s *Status) OnStyleChange(st style.Style) {
	s.Base.OnStyleChange(st)

	s.BackgroundColor = st.Background
	s.BorderColor = style.Lighten(s.BackgroundColor, 0.1)

	s.start.Background = st.Background
	s.start.Color = st.OnBackground

	s.center.Background = st.Background
	s.center.Color = st.OnBackground

	s.end.Background = st.Background
	s.end.Color = st.OnBackground
}
