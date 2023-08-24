package wlroots

// #include <wayland-server-core.h>
// #include <wlr/backend.h>
// #include <wlr/render/allocator.h>
// #include <wlr/render/wlr_renderer.h>
// #include <wlr/types/wlr_cursor.h>
// #include <wlr/types/wlr_compositor.h>
// #include <wlr/types/wlr_data_device.h>
// #include <wlr/types/wlr_input_device.h>
// #include <wlr/types/wlr_keyboard.h>
// #include <wlr/types/wlr_output.h>
// #include <wlr/types/wlr_output_layout.h>
// #include <wlr/types/wlr_pointer.h>
// #include <wlr/types/wlr_scene.h>
// #include <wlr/types/wlr_seat.h>
// #include <wlr/types/wlr_xcursor_manager.h>
// #include <wlr/types/wlr_xdg_shell.h>
// #include <wlr/util/log.h>
//
// #cgo pkg-config: wlroots wayland-server
// #cgo CFLAGS: -D_GNU_SOURCE -DWLR_USE_UNSTABLE
import "C"
import (
	"fmt"
	"unsafe"
)

type Display struct {
	unwrap *C.struct_wl_display
	Events map[string]*Signal
}

func NewDisplay() (*Display, error) {
	ptr := C.wl_display_create()
	if ptr == nil {
		return nil, fmt.Errorf("failed to create display")
	}
	return &Display{
		unwrap: ptr,
		Events: map[string]*Signal{},
	}, nil
}

func (d *Display) AddSocketAuto() string {
	sock := C.wl_display_add_socket_auto(d.unwrap)
	if sock == nil {
		return ""
	}
	return C.GoString(sock)
}

func (d *Display) CreateCompositor(renderer *Renderer) {
	C.wlr_compositor_create(d.unwrap, renderer.unwrap)
}

func (d *Display) CreateDataDeviceManager() {
	C.wlr_data_device_manager_create(d.unwrap)
}

func (d *Display) Run() {
	C.wl_display_run(d.unwrap)
}

func (d *Display) Destroy() {
	C.wl_display_destroy(d.unwrap)
}

type Event int

const (
	EventNewOutput Event = iota
	EventNewInput
)

type Backend struct {
	unwrap *C.struct_wlr_backend
	events map[Event]*Signal
}

func NewBackend(display *Display) (*Backend, error) {
	ptr := C.wlr_backend_autocreate(display.unwrap)
	if ptr == nil {
		return nil, fmt.Errorf("failed to create backend")
	}
	b := &Backend{
		unwrap: ptr,
		events: map[Event]*Signal{},
	}

	b.events[EventNewOutput] = &Signal{unwrap: b.unwrap.events.new_output}
	b.events[EventNewInput] = &Signal{unwrap: b.unwrap.events.new_input}

	return b, nil
}

func (b *Backend) Event(id Event) *Signal {
	s, ok := b.events[id]
	if !ok {
		return nil
	}
	return s
}

func (b *Backend) Start() bool {
	status := C.wlr_backend_start(b.unwrap)
	return bool(status)
}

func (b *Backend) Destroy() {
	C.wlr_backend_destroy(b.unwrap)
}

type Renderer struct {
	unwrap *C.struct_wlr_renderer
}

func NewRenderer(backend *Backend) (*Renderer, error) {
	ptr := C.wlr_renderer_autocreate(backend.unwrap)
	if ptr == nil {
		return nil, fmt.Errorf("failed to create wlr_renderer")
	}

	return &Renderer{
		unwrap: ptr,
	}, nil
}

func (r *Renderer) InitDisplay(display *Display) {
	C.wlr_renderer_init_wl_display(r.unwrap, display.unwrap)
}

type Allocator struct {
	unwrap *C.struct_wlr_allocator
}

func NewAllocator(backend *Backend, renderer *Renderer) (*Allocator, error) {
	ptr := C.wlr_allocator_autocreate(backend.unwrap, renderer.unwrap)
	if ptr == nil {
		return nil, fmt.Errorf("failed to create allocator")
	}

	return &Allocator{
		unwrap: ptr,
	}, nil
}

func (a *Allocator) Destroy() {
	C.wlr_allocator_destroy(a.unwrap)
}

type Output struct {
	unwrap *C.struct_wlr_output
}

type OutputLayout struct {
	unwrap *C.struct_wlr_output_layout
}

func NewOutputLayout() (*OutputLayout, error) {
	ptr := C.wlr_output_layout_create()
	if ptr == nil {
		return nil, fmt.Errorf("failed to create wlr_output_layout")
	}
	return &OutputLayout{
		unwrap: ptr,
	}, nil
}

func (o *OutputLayout) Add(output *Output) {
	C.wlr_output_layout_add_auto(o.unwrap, output.unwrap)
}

func (o *OutputLayout) Destroy() {
	C.wlr_output_layout_destroy(o.unwrap)
}

type List struct {
	unwrap C.struct_wl_list
}

func NewList() *List {
	return &List{}
}

func (l *List) Init() {
	C.wl_list_init(&l.unwrap)
}

func (l *List) Insert(e *List) {
	C.wl_list_insert(&l.unwrap, &e.unwrap)
}

func (l *List) Remove() {
	C.wl_list_remove(&l.unwrap)
}

type Signal struct {
	unwrap C.struct_wl_signal
}

type Listener struct {
	unwrap   C.struct_wl_listener
	callback func(data unsafe.Pointer)
}

func NewListener(callback func(unsafe.Pointer)) *Listener {
	return &Listener{
		callback: callback,
	}
}

func (l *Listener) Connect(signal *Signal) {
	l.unwrap.notify = (C.wl_notify_func_t)(unsafe.Pointer(&l.callback))
	C.wl_signal_add(&signal.unwrap, &l.unwrap)
}

type Scene struct {
	unwrap *C.struct_wlr_scene
}

func NewScene() (*Scene, error) {
	return &Scene{
		unwrap: C.wlr_scene_create(),
	}, nil
}

func (s *Scene) AttachOutputLayout(l *OutputLayout) {
	C.wlr_scene_attach_output_layout(s.unwrap, l.unwrap)
}

const (
	EventNewSurface Event = EventNewOutput + 1
)

type XdgShell struct {
	unwrap *C.struct_wlr_xdg_shell
	events map[Event]*Signal
}

func NewXdgShell(display *Display) (*XdgShell, error) {
	ptr := C.wlr_xdg_shell_create(display.unwrap)
	xdgShell := &XdgShell{
		unwrap: ptr,
		events: map[Event]*Signal{},
	}
	xdgShell.events[EventNewSurface] = &Signal{xdgShell.unwrap.events.new_surface}

	return xdgShell, nil
}

func (x *XdgShell) Event(e Event) *Signal {
	return x.events[e]
}
