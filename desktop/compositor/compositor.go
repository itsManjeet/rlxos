package compositor

import (
	"fmt"
	"log"
	"rlxos/pkg/wlroots"
	"unsafe"
)

type Compositor struct {
	display   *wlroots.Display
	backend   *wlroots.Backend
	renderer  *wlroots.Renderer
	allocator *wlroots.Allocator
	scene     *wlroots.Scene

	outputLayout   *wlroots.OutputLayout
	outputs        *wlroots.List
	outputListener *wlroots.Listener

	xdgShell           *wlroots.XdgShell
	xdgSurfaceListener *wlroots.Listener
	views              *wlroots.List
}

func New() (c *Compositor, err error) {
	c = &Compositor{}
	c.display, err = wlroots.NewDisplay()
	if err != nil {
		return nil, err
	}
	c.backend, err = wlroots.NewBackend(c.display)
	if err != nil {
		return nil, err
	}

	c.renderer, err = wlroots.NewRenderer(c.backend)
	if err != nil {
		return nil, err
	}

	c.renderer.InitDisplay(c.display)

	c.allocator, err = wlroots.NewAllocator(c.backend, c.renderer)
	if err != nil {
		return nil, err
	}

	c.display.CreateCompositor(c.renderer)
	c.display.CreateDataDeviceManager()

	c.outputLayout, err = wlroots.NewOutputLayout()
	if err != nil {
		return nil, err
	}

	c.outputs = wlroots.NewList()
	c.outputListener = wlroots.NewListener(func(p unsafe.Pointer) {

	})
	c.outputListener.Connect(c.backend.Event(wlroots.EventNewOutput))

	c.scene, err = wlroots.NewScene()
	if err != nil {
		return nil, err
	}
	c.scene.AttachOutputLayout(c.outputLayout)

	c.views = wlroots.NewList()
	c.xdgSurfaceListener = wlroots.NewListener(func(p unsafe.Pointer) {

	})
	c.xdgShell, err = wlroots.NewXdgShell(c.display)
	if err != nil {
		return nil, err
	}
	c.xdgSurfaceListener.Connect(c.xdgShell.Event(wlroots.EventNewSurface))

	return c, nil
}

func (c *Compositor) Start() error {
	socket := c.display.AddSocketAuto()
	if len(socket) == 0 {
		return fmt.Errorf("failed to create socket")
	}
	log.Println("WAYLAND SOCKET", socket)

	if !c.backend.Start() {
		return fmt.Errorf("failed to start backend")
	}

	c.display.Run()

	return nil
}

func (c *Compositor) Destroy() {
	c.backend.Destroy()
	c.display.Destroy()
}
