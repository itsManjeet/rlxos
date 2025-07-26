package main

/*
#cgo pkg-config: wlroots-0.18 wayland-server xkbcommon
#cgo CFLAGS: -DWLR_USE_UNSTABLE
#include <wayland-server-core.h>
#include <wlr/backend.h>
#include <wlr/render/allocator.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/types/wlr_cursor.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_data_device.h>
#include <wlr/types/wlr_input_device.h>
#include <wlr/types/wlr_keyboard.h>
#include <wlr/types/wlr_output.h>
#include <wlr/types/wlr_output_layout.h>
#include <wlr/types/wlr_pointer.h>
#include <wlr/types/wlr_scene.h>
#include <wlr/types/wlr_seat.h>
#include <wlr/types/wlr_subcompositor.h>
#include <wlr/types/wlr_xcursor_manager.h>
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/types/wlr_layer_shell_v1.h>
#include <wlr/util/log.h>
#include <xkbcommon/xkbcommon.h>

extern void display_new_output(struct wl_listener *listener, void* data);
extern void display_new_input(struct wl_listener *listener, void* data);
extern void display_new_xdg_toplevel(struct wl_listener *listener, void* data);
extern void display_new_xdg_popup(struct wl_listener *listener, void* data);
extern void display_cursor_motion(struct wl_listener *listener, void* data);
extern void display_cursor_motion_absolute(struct wl_listener *listener, void* data);
extern void display_cursor_button(struct wl_listener *listener, void* data);
extern void display_cursor_axis(struct wl_listener *listener, void* data);
extern void display_cursor_frame(struct wl_listener *listener, void* data);
extern void display_request_set_cursor(struct wl_listener *listener, void* data);
extern void display_request_set_selection(struct wl_listener *listener, void* data);
extern void display_output_frame(struct wl_listener *listener, void* data);
extern void display_output_request_state(struct wl_listener *listener, void* data);
extern void display_output_destroy(struct wl_listener *listener, void* data);
extern void display_keyboard_handle_modifiers(struct wl_listener *listener, void* data);
extern void display_keyboard_handle_key(struct wl_listener *listener, void* data);
extern void display_keyboard_destroy(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_map(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_unmap(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_commit(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_destroy(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_request_move(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_request_resize(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_request_maximize(struct wl_listener *listener, void* data);
extern void display_xdg_toplevel_request_fullscreen(struct wl_listener *listener, void* data);
extern void display_xdg_popup_commit(struct wl_listener *listener, void* data);
extern void display_xdg_popup_destroy(struct wl_listener *listener, void* data);
extern void display_new_layer_surface(struct wl_listener *listener, void *data);
extern void display_layer_surface_destroy(struct wl_listener *listener, void *data);
*/
import "C"
import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"slices"
	"syscall"
	"time"
	"unsafe"
)

type Server struct {
	display     *C.struct_wl_display
	backend     *C.struct_wlr_backend
	renderer    *C.struct_wlr_renderer
	allocator   *C.struct_wlr_allocator
	scene       *C.struct_wlr_scene
	sceneLayout *C.struct_wlr_scene_output_layout

	xdgShell       *C.struct_wlr_xdg_shell
	newXdgTopLevel C.struct_wl_listener
	newXdgPopup    C.struct_wl_listener
	topLevels      []*Toplevel

	layerShell      *C.struct_wlr_layer_shell_v1
	newLayerSurface C.struct_wl_listener

	background *C.struct_wlr_scene_rect

	cursor          *C.struct_wlr_cursor
	cursorManager   *C.struct_wlr_xcursor_manager
	cursorMotion    C.struct_wl_listener
	cursorMotionAbs C.struct_wl_listener
	cursorButton    C.struct_wl_listener
	cursorAxis      C.struct_wl_listener
	cursorFrame     C.struct_wl_listener

	seat                *C.struct_wlr_seat
	newInput            C.struct_wl_listener
	requestCursor       C.struct_wl_listener
	requestSetSelection C.struct_wl_listener
	keyboards           []*Keyboard
	cursorMode          CursorMode
	grabbedToplevel     *Toplevel
	grabX, grabY        float64
	grabGeo             C.struct_wlr_box
	resizeEdges         uint32

	outputLayout *C.struct_wlr_output_layout
	outputs      []*Output
	newOutput    C.struct_wl_listener
}

type Output struct {
	server       *Server
	output       *C.struct_wlr_output
	frame        C.struct_wl_listener
	requestState C.struct_wl_listener
	destroy      C.struct_wl_listener
}

type Toplevel struct {
	server            *Server
	toplevel          *C.struct_wlr_xdg_toplevel
	sceneTree         *C.struct_wlr_scene_tree
	mmap              C.struct_wl_listener
	unmap             C.struct_wl_listener
	commit            C.struct_wl_listener
	destroy           C.struct_wl_listener
	requestMove       C.struct_wl_listener
	requestResize     C.struct_wl_listener
	requestMaximize   C.struct_wl_listener
	requestFullscreen C.struct_wl_listener
}

type Popup struct {
	backend *C.struct_wlr_xdg_popup
	commit  C.struct_wl_listener
	destroy C.struct_wl_listener
}

type Keyboard struct {
	server   *Server
	keyboard *C.struct_wlr_keyboard

	modifiers C.struct_wl_listener
	key       C.struct_wl_listener
	destroy   C.struct_wl_listener
}

func (s *Server) Init() error {
	C.wlr_log_init(C.WLR_DEBUG, nil)

	s.display = C.wl_display_create()
	s.backend = C.wlr_backend_autocreate(C.wl_display_get_event_loop(s.display), nil)
	if s.backend == nil {
		return fmt.Errorf("failed to create wlr_backend")
	}

	s.renderer = C.wlr_renderer_autocreate(s.backend)
	if s.renderer == nil {
		return fmt.Errorf("failed to created wlr_renderer")
	}

	C.wlr_renderer_init_wl_display(s.renderer, s.display)

	s.allocator = C.wlr_allocator_autocreate(s.backend, s.renderer)
	if s.allocator == nil {
		return fmt.Errorf("failed to create wlr_allocator")
	}

	C.wlr_compositor_create(s.display, 5, s.renderer)
	C.wlr_subcompositor_create(s.display)
	C.wlr_data_device_manager_create(s.display)

	s.outputLayout = C.wlr_output_layout_create(s.display)
	s.newOutput.notify = (*[0]byte)(C.display_new_output)
	C.wl_signal_add(&s.backend.events.new_output, &s.newOutput)

	s.scene = C.wlr_scene_create()
	s.sceneLayout = C.wlr_scene_attach_output_layout(s.scene, s.outputLayout)

	s.xdgShell = C.wlr_xdg_shell_create(s.display, 3)
	s.newXdgTopLevel.notify = (*[0]byte)(C.display_new_xdg_toplevel)
	C.wl_signal_add(&s.xdgShell.events.new_toplevel, &s.newXdgTopLevel)
	s.newXdgPopup.notify = (*[0]byte)(C.display_new_xdg_popup)
	C.wl_signal_add(&s.xdgShell.events.new_popup, &s.newXdgPopup)

	s.layerShell = C.wlr_layer_shell_v1_create(s.display, 1)
	s.newLayerSurface.notify = (*[0]byte)(C.display_new_layer_surface)
	C.wl_signal_add(&s.layerShell.events.new_surface, &s.newLayerSurface)

	color := [4]C.float{0.1, 0.1, 0.1, 1.0}
	s.background = C.wlr_scene_rect_create(&s.scene.tree, 0, 0, &color[0])

	s.cursor = C.wlr_cursor_create()
	C.wlr_cursor_attach_output_layout(s.cursor, s.outputLayout)
	s.cursorManager = C.wlr_xcursor_manager_create(nil, 24)
	os.Setenv("XCURSOR_SIZE", "24")

	s.cursorMode = CursorModePassThrough
	s.cursorMotion.notify = (*[0]byte)(C.display_cursor_motion)
	C.wl_signal_add(&s.cursor.events.motion, &s.cursorMotion)
	s.cursorMotionAbs.notify = (*[0]byte)(C.display_cursor_motion_absolute)
	C.wl_signal_add(&s.cursor.events.motion_absolute, &s.cursorMotionAbs)
	s.cursorButton.notify = (*[0]byte)(C.display_cursor_button)
	C.wl_signal_add(&s.cursor.events.button, &s.cursorButton)
	s.cursorAxis.notify = (*[0]byte)(C.display_cursor_axis)
	C.wl_signal_add(&s.cursor.events.axis, &s.cursorAxis)
	s.cursorFrame.notify = (*[0]byte)(C.display_cursor_frame)
	C.wl_signal_add(&s.cursor.events.frame, &s.cursorFrame)

	s.newInput.notify = (*[0]byte)(C.display_new_input)
	C.wl_signal_add(&s.backend.events.new_input, &s.newInput)

	s.seat = C.wlr_seat_create(s.display, C.CString("seat0"))
	s.requestCursor.notify = (*[0]byte)(C.display_request_set_cursor)
	C.wl_signal_add(&s.seat.events.request_set_cursor, &s.requestCursor)
	s.requestSetSelection.notify = (*[0]byte)(C.display_request_set_selection)
	C.wl_signal_add(&s.seat.events.request_set_selection, &s.requestSetSelection)

	return nil
}

func (s *Server) Run() error {
	c_socket := C.wl_display_add_socket_auto(s.display)
	if c_socket == nil {
		return fmt.Errorf("failed to create wl_display socket")
	}
	socket := C.GoString(c_socket)

	if !C.wlr_backend_start(s.backend) {
		return fmt.Errorf("failed to start wlr_backend")
	}

	os.Setenv("WAYLAND_DISPLAY", socket)
	log.Printf("running wayland compositor on WAYLAND_DISPLAY=%s", socket)

	C.wlr_cursor_set_xcursor(s.cursor, s.cursorManager, C.CString("default"))

	C.wl_display_run(s.display)

	return nil
}

func (s *Server) Destroy() {
	C.wl_display_destroy_clients(s.display)
	C.wlr_scene_node_destroy(&s.scene.tree.node)
	C.wlr_xcursor_manager_destroy(s.cursorManager)
	C.wlr_cursor_destroy(s.cursor)
	C.wlr_allocator_destroy(s.allocator)
	C.wlr_renderer_destroy(s.renderer)
	C.wlr_backend_destroy(s.backend)
	C.wl_display_destroy(s.display)
}
func (s *Server) desktopToplevelAt(lx, ly C.double) (*Toplevel, *C.struct_wlr_surface, C.double, C.double) {
	var sx, sy C.double
	var surface *C.struct_wlr_surface

	node := C.wlr_scene_node_at(&s.scene.tree.node, lx, ly, &sx, &sy)
	if node == nil || node._type != C.WLR_SCENE_NODE_BUFFER {
		return nil, nil, 0.0, 0.0
	}

	sceneBuffer := C.wlr_scene_buffer_from_node(node)
	sceneSurface := C.wlr_scene_surface_try_from_buffer(sceneBuffer)

	if sceneSurface == nil {
		return nil, nil, 0.0, 0.0
	}

	surface = sceneSurface.surface
	tree := node.parent

	for tree != nil && tree.node.data == nil {
		tree = tree.node.parent
	}
	return (*Toplevel)(unsafe.Pointer(tree.node.data)), surface, sx, sy
}

func (s *Server) run(bin string, args ...string) error {
	cmd := exec.Command(bin, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setsid: true,
	}

	return cmd.Start()
}

func (s *Server) handleKeyBinding(sym C.xkb_keysym_t) bool {
	switch sym {
	case C.XKB_KEY_Escape:
		C.wl_display_terminate(s.display)
	case C.XKB_KEY_Return:
		s.run("foot")
		return true
	}
	return false
}

func (s *Server) OnNewKeyboard(device *C.struct_wlr_input_device) {
	wlr_keyboard := C.wlr_keyboard_from_input_device(device)
	keyboard := &Keyboard{
		server:   s,
		keyboard: wlr_keyboard,
	}

	context := C.xkb_context_new(C.XKB_CONTEXT_NO_FLAGS)
	defer C.xkb_context_unref(context)

	keymap := C.xkb_keymap_new_from_names(context, nil, C.XKB_KEYMAP_COMPILE_NO_FLAGS)
	defer C.xkb_keymap_unref(keymap)

	C.wlr_keyboard_set_keymap(wlr_keyboard, keymap)
	C.wlr_keyboard_set_repeat_info(wlr_keyboard, 25, 600)

	keyboard.modifiers.notify = (*[0]byte)(C.display_keyboard_handle_modifiers)
	C.wl_signal_add(&keyboard.keyboard.events.modifiers, &keyboard.modifiers)

	keyboard.key.notify = (*[0]byte)(C.display_keyboard_handle_key)
	C.wl_signal_add(&keyboard.keyboard.events.key, &keyboard.key)

	keyboard.destroy.notify = (*[0]byte)(C.display_keyboard_destroy)
	C.wl_signal_add(&device.events.destroy, &keyboard.destroy)

	C.wlr_seat_set_keyboard(s.seat, keyboard.keyboard)

	s.keyboards = append(s.keyboards, keyboard)
}

func (s *Server) OnNewPointer(device *C.struct_wlr_input_device) {
	C.wlr_cursor_attach_input_device(s.cursor, device)
}

func (s *Server) focusTopLevel(toplevel *Toplevel, surface *C.struct_wlr_surface) {
	if toplevel == nil {
		return
	}

	prev_surface := s.seat.keyboard_state.focused_surface
	if prev_surface == surface {
		return
	}

	if prev_surface != nil {
		prev_toplevel := C.wlr_xdg_toplevel_try_from_wlr_surface(prev_surface)
		if prev_toplevel != nil {
			C.wlr_xdg_toplevel_set_activated(prev_toplevel, false)
		}
	}

	keyboard := C.wlr_seat_get_keyboard(s.seat)
	C.wlr_scene_node_raise_to_top(&toplevel.sceneTree.node)

	if idx := slices.Index(s.topLevels, toplevel); idx != -1 {
		s.topLevels = slices.Delete(s.topLevels, idx, idx+1)
	}
	s.topLevels = append(s.topLevels, toplevel)

	C.wlr_xdg_toplevel_set_activated(toplevel.toplevel, true)
	if keyboard != nil {
		C.wlr_seat_keyboard_notify_enter(s.seat, toplevel.toplevel.base.surface,
			(*C.uint32_t)(&keyboard.keycodes[0]), keyboard.num_keycodes, &keyboard.modifiers)
	}
}

func (s *Server) beginInteractive(toplevel *Toplevel, mode CursorMode, edges C.uint32_t) {
	focused_surface := s.seat.pointer_state.focused_surface
	if toplevel.toplevel.base.surface != C.wlr_surface_get_root_surface(focused_surface) {
		return
	}
	s.grabbedToplevel = toplevel
	s.cursorMode = mode

	if mode == CursorModeMove {
		s.grabX = float64(s.cursor.x - C.double(toplevel.sceneTree.node.x))
		s.grabY = float64(s.cursor.y - C.double(toplevel.sceneTree.node.y))
	} else {
		var geoBox C.struct_wlr_box
		C.wlr_xdg_surface_get_geometry(toplevel.toplevel.base, &geoBox)

		borderX := toplevel.sceneTree.node.x + geoBox.x
		if edges&C.WLR_EDGE_RIGHT != 0 {
			borderX += geoBox.width
		}

		borderY := toplevel.sceneTree.node.y + geoBox.y
		if edges&C.WLR_EDGE_BOTTOM != 0 {
			borderY += geoBox.height
		}
		s.grabX = float64(s.cursor.x - C.double(borderX))
		s.grabY = float64(s.cursor.y - C.double(borderY))

		s.grabGeo = geoBox
		s.grabGeo.x += toplevel.sceneTree.node.x
		s.grabGeo.y += toplevel.sceneTree.node.y

		s.resizeEdges = uint32(edges)
	}
}

func (s *Server) resetCursorMode() {
	s.cursorMode = CursorModePassThrough
	s.grabbedToplevel = nil
}

func containerOf[C any, M any](m *M, offset uintptr) *C {
	return (*C)(unsafe.Pointer(uintptr(unsafe.Pointer(m)) - offset))
}

//export display_new_output
func display_new_output(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.newOutput))

	wlr_output := (*C.struct_wlr_output)(data)

	C.wlr_output_init_render(wlr_output, s.allocator, s.renderer)

	var state C.struct_wlr_output_state
	C.wlr_output_state_init(&state)
	C.wlr_output_state_set_enabled(&state, true)

	mode := C.wlr_output_preferred_mode(wlr_output)
	if mode != nil {
		C.wlr_output_state_set_mode(&state, mode)
	}
	C.wlr_scene_rect_set_size(s.background, mode.width, mode.height)
	C.wlr_output_commit_state(wlr_output, &state)
	C.wlr_output_state_finish(&state)

	output := Output{
		output: wlr_output,
		server: s,
	}

	output.frame.notify = (*[0]byte)(C.display_output_frame)
	C.wl_signal_add(&wlr_output.events.frame, &output.frame)

	output.requestState.notify = (*[0]byte)(C.display_output_request_state)
	C.wl_signal_add(&wlr_output.events.request_state, &output.requestState)

	output.destroy.notify = (*[0]byte)(C.display_output_destroy)
	C.wl_signal_add(&wlr_output.events.destroy, &output.destroy)

	s.outputs = append(s.outputs, &output)
	layoutOutput := C.wlr_output_layout_add_auto(s.outputLayout, wlr_output)
	sceneOutput := C.wlr_scene_output_create(s.scene, wlr_output)
	C.wlr_scene_output_layout_add_output(s.sceneLayout, layoutOutput, sceneOutput)

}

//export display_new_input
func display_new_input(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.newInput))
	device := (*C.struct_wlr_input_device)(data)
	switch device._type {
	case C.WLR_INPUT_DEVICE_KEYBOARD:
		s.OnNewKeyboard(device)
	case C.WLR_INPUT_DEVICE_POINTER:
		s.OnNewPointer(device)
	}

	caps := C.WL_SEAT_CAPABILITY_POINTER
	if len(s.keyboards) != 0 {
		caps |= C.WL_SEAT_CAPABILITY_KEYBOARD
	}
	C.wlr_seat_set_capabilities(s.seat, C.uint32_t(caps))
}

//export display_new_xdg_toplevel
func display_new_xdg_toplevel(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.newXdgTopLevel))
	xdgToplevel := (*C.struct_wlr_xdg_toplevel)(data)

	toplevel := &Toplevel{
		server:   s,
		toplevel: xdgToplevel,
	}
	toplevel.sceneTree = C.wlr_scene_xdg_surface_create(&toplevel.server.scene.tree, xdgToplevel.base)
	toplevel.sceneTree.node.data = unsafe.Pointer(toplevel)
	xdgToplevel.base.data = unsafe.Pointer(toplevel.sceneTree)

	toplevel.mmap.notify = (*[0]byte)(C.display_xdg_toplevel_map)
	C.wl_signal_add(&xdgToplevel.base.surface.events._map, &toplevel.mmap)

	toplevel.unmap.notify = (*[0]byte)(C.display_xdg_toplevel_unmap)
	C.wl_signal_add(&xdgToplevel.base.surface.events.unmap, &toplevel.unmap)

	toplevel.commit.notify = (*[0]byte)(C.display_xdg_toplevel_commit)
	C.wl_signal_add(&xdgToplevel.base.surface.events.commit, &toplevel.commit)

	toplevel.destroy.notify = (*[0]byte)(C.display_xdg_toplevel_destroy)
	C.wl_signal_add(&xdgToplevel.base.surface.events.destroy, &toplevel.destroy)

	toplevel.requestMove.notify = (*[0]byte)(C.display_xdg_toplevel_request_move)
	C.wl_signal_add(&xdgToplevel.events.request_move, &toplevel.requestMove)

	toplevel.requestResize.notify = (*[0]byte)(C.display_xdg_toplevel_request_resize)
	C.wl_signal_add(&xdgToplevel.events.request_resize, &toplevel.requestResize)

	toplevel.requestMaximize.notify = (*[0]byte)(C.display_xdg_toplevel_request_maximize)
	C.wl_signal_add(&xdgToplevel.events.request_maximize, &toplevel.requestMaximize)

	toplevel.requestFullscreen.notify = (*[0]byte)(C.display_xdg_toplevel_request_fullscreen)
	C.wl_signal_add(&xdgToplevel.events.request_fullscreen, &toplevel.requestFullscreen)
}

//export display_new_xdg_popup
func display_new_xdg_popup(listener *C.struct_wl_listener, data unsafe.Pointer) {
	xdg_popup := (*C.struct_wlr_xdg_popup)(data)
	popup := &Popup{
		backend: xdg_popup,
	}

	parent := C.wlr_xdg_surface_try_from_wlr_surface(xdg_popup.parent)
	if parent == nil {
		log.Printf("pop %v has no parent", xdg_popup)
		return
	}

	parent_tree := (*C.struct_wlr_scene_tree)(parent.data)
	xdg_popup.base.data = unsafe.Pointer(C.wlr_scene_xdg_surface_create(parent_tree, xdg_popup.base))

	popup.commit.notify = (*[0]byte)(C.display_xdg_popup_commit)
	C.wl_signal_add(&xdg_popup.base.surface.events.commit, &popup.commit)

	popup.destroy.notify = (*[0]byte)(C.display_xdg_popup_destroy)
	C.wl_signal_add(&xdg_popup.events.destroy, &popup.destroy)
}

func (s *Server) processCursorMove(time C.uint32_t) {
	toplevel := s.grabbedToplevel
	C.wlr_scene_node_set_position(&toplevel.sceneTree.node,
		C.int(s.cursor.x-C.double(s.grabX)),
		C.int(s.cursor.y-C.double(s.grabY)),
	)
}

func (s *Server) processCursorResize(time C.uint32_t) {
	toplevel := s.grabbedToplevel
	borderX := s.cursor.x - C.double(s.grabX)
	borderY := s.cursor.y - C.double(s.grabY)

	newLeft := s.grabGeo.x
	newRight := s.grabGeo.x + s.grabGeo.width
	newTop := s.grabGeo.y
	newBottom := s.grabGeo.y + s.grabGeo.height

	if s.resizeEdges&C.WLR_EDGE_TOP != 0 {
		newTop = C.int(borderY)
		if newTop >= newBottom {
			newTop = newBottom - 1
		}
	} else if s.resizeEdges&C.WLR_EDGE_BOTTOM != 0 {
		newBottom = C.int(borderY)
		if newBottom <= newTop {
			newBottom = newTop + 1
		}
	}

	if s.resizeEdges&C.WLR_EDGE_LEFT != 0 {
		newLeft = C.int(borderX)
		if newLeft >= newRight {
			newLeft = newRight - 1
		}
	} else if s.resizeEdges&C.WLR_EDGE_RIGHT != 0 {
		newRight = C.int(borderX)
		if newRight <= newLeft {
			newRight = newLeft + 1
		}
	}

	var geoBox C.struct_wlr_box
	C.wlr_xdg_surface_get_geometry(toplevel.toplevel.base, &geoBox)
	C.wlr_scene_node_set_position(&toplevel.sceneTree.node,
		newLeft-geoBox.x, newTop-geoBox.y)

	newWidth := newRight - newLeft
	newHeight := newBottom - newTop

	C.wlr_xdg_toplevel_set_size(toplevel.toplevel, newWidth, newHeight)
}

func (s *Server) processCursorMotion(time C.uint32_t) {
	switch s.cursorMode {
	case CursorModeMove:
		s.processCursorMove(time)
		return
	case CursorModeResize:
		s.processCursorResize(time)
		return
	}

	toplevel, surface, sx, sy := s.desktopToplevelAt(s.cursor.x, s.cursor.y)
	if toplevel == nil {
		C.wlr_cursor_set_xcursor(s.cursor, s.cursorManager, C.CString("default"))
	}

	if surface != nil {
		C.wlr_seat_pointer_notify_enter(s.seat, surface, sx, sy)
		C.wlr_seat_pointer_notify_motion(s.seat, time, sx, sy)
	} else {
		C.wlr_seat_pointer_clear_focus(s.seat)
	}
}

//export display_cursor_motion
func display_cursor_motion(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.cursorMotion))
	event := (*C.struct_wlr_pointer_motion_event)(data)

	C.wlr_cursor_move(s.cursor, &event.pointer.base,
		event.delta_x, event.delta_y)
	s.processCursorMotion(event.time_msec)
}

//export display_cursor_motion_absolute
func display_cursor_motion_absolute(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.cursorMotionAbs))
	event := (*C.struct_wlr_pointer_motion_absolute_event)(data)

	C.wlr_cursor_warp_absolute(s.cursor, &event.pointer.base, event.x, event.y)
	s.processCursorMotion(event.time_msec)
}

//export display_cursor_button
func display_cursor_button(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.cursorButton))

	event := (*C.struct_wlr_pointer_button_event)(data)
	C.wlr_seat_pointer_notify_button(s.seat,
		event.time_msec, event.button, event.state)

	toplevel, surface, _, _ := s.desktopToplevelAt(s.cursor.x, s.cursor.y)
	if event.state == C.WL_POINTER_BUTTON_STATE_RELEASED {
		s.resetCursorMode()
	} else {
		s.focusTopLevel(toplevel, surface)
	}

}

//export display_cursor_axis
func display_cursor_axis(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.cursorAxis))
	event := (*C.struct_wlr_pointer_axis_event)(data)
	C.wlr_seat_pointer_notify_axis(s.seat,
		event.time_msec, event.orientation, event.delta,
		event.delta_discrete, event.source, event.relative_direction)
}

//export display_cursor_frame
func display_cursor_frame(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.cursorFrame))
	C.wlr_seat_pointer_notify_frame(s.seat)
}

//export display_request_set_cursor
func display_request_set_cursor(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.requestCursor))
	event := (*C.struct_wlr_seat_pointer_request_set_cursor_event)(data)
	focused_client := (*C.struct_wlr_seat_client)(s.seat.pointer_state.focused_client)

	if focused_client == event.seat_client {
		C.wlr_cursor_set_surface(s.cursor, event.surface, event.hotspot_x, event.hotspot_y)
	}
}

//export display_request_set_selection
func display_request_set_selection(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.requestSetSelection))
	event := (*C.struct_wlr_seat_request_set_selection_event)(data)
	C.wlr_seat_set_selection(s.seat, event.source, event.serial)
}

//export display_output_frame
func display_output_frame(listener *C.struct_wl_listener, data unsafe.Pointer) {
	o := containerOf[Output](listener, unsafe.Offsetof(Output{}.frame))
	scene := o.server.scene
	sceneOutput := C.wlr_scene_get_scene_output(scene, o.output)
	C.wlr_scene_output_commit(sceneOutput, nil)

	now := clockGetTime()
	C.wlr_scene_output_send_frame_done(sceneOutput, (*C.struct_timespec)(unsafe.Pointer(&now)))
}

//export display_output_request_state
func display_output_request_state(listener *C.struct_wl_listener, data unsafe.Pointer) {
	o := containerOf[Output](listener, unsafe.Offsetof(Output{}.frame))
	event := (*C.struct_wlr_output_event_request_state)(data)
	C.wlr_output_commit_state(o.output, event.state)
}

//export display_output_destroy
func display_output_destroy(listener *C.struct_wl_listener, data unsafe.Pointer) {
	o := containerOf[Output](listener, unsafe.Offsetof(Output{}.frame))
	C.wl_list_remove(&o.frame.link)
	C.wl_list_remove(&o.requestState.link)
	C.wl_list_remove(&o.destroy.link)

	if idx := slices.Index(o.server.outputs, o); idx != -1 {
		o.server.outputs = slices.Delete(o.server.outputs, idx, idx+1)
	}
}

func clockGetTime() syscall.Timespec {
	return syscall.NsecToTimespec(time.Now().UnixNano())
}

//export display_keyboard_handle_modifiers
func display_keyboard_handle_modifiers(listener *C.struct_wl_listener, data unsafe.Pointer) {
	k := containerOf[Keyboard](listener, unsafe.Offsetof(Keyboard{}.modifiers))
	C.wlr_seat_set_keyboard(k.server.seat, k.keyboard)
	C.wlr_seat_keyboard_notify_modifiers(k.server.seat, &k.keyboard.modifiers)
}

//export display_keyboard_handle_key
func display_keyboard_handle_key(listener *C.struct_wl_listener, data unsafe.Pointer) {
	k := containerOf[Keyboard](listener, unsafe.Offsetof(Keyboard{}.key))
	event := (*C.struct_wlr_keyboard_key_event)(data)

	keycode := event.keycode + 8
	var syms *C.xkb_keysym_t
	n_syms := C.xkb_state_key_get_syms(
		k.keyboard.xkb_state, keycode, &syms,
	)
	handled := false

	modifiers := C.wlr_keyboard_get_modifiers(k.keyboard)
	if (modifiers&C.WLR_MODIFIER_ALT) != 0 &&
		event.state == C.WL_KEYBOARD_KEY_STATE_PRESSED {
		for i := C.int(0); i < n_syms; i++ {
			handled = k.server.handleKeyBinding(*(*C.xkb_keysym_t)(unsafe.Pointer(uintptr(unsafe.Pointer(syms)) + uintptr(i)*unsafe.Sizeof(*syms))))
		}
	}
	if !handled {
		C.wlr_seat_set_keyboard(k.server.seat, k.keyboard)
		C.wlr_seat_keyboard_notify_key(k.server.seat, event.time_msec,
			event.keycode, C.uint32_t(event.state))
	}
}

//export display_keyboard_destroy
func display_keyboard_destroy(listener *C.struct_wl_listener, data unsafe.Pointer) {
	k := containerOf[Keyboard](listener, unsafe.Offsetof(Keyboard{}.destroy))
	C.wl_list_remove(&k.modifiers.link)
	C.wl_list_remove(&k.key.link)
	C.wl_list_remove(&k.destroy.link)

	if idx := slices.Index(k.server.keyboards, k); idx != -1 {
		k.server.keyboards = slices.Delete(k.server.keyboards, idx, idx+1)
	}
}

//export display_xdg_toplevel_map
func display_xdg_toplevel_map(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.mmap))
	t.server.topLevels = append(t.server.topLevels, t)
	t.server.focusTopLevel(t, t.toplevel.base.surface)
}

//export display_xdg_toplevel_unmap
func display_xdg_toplevel_unmap(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.unmap))
	if t == t.server.grabbedToplevel {
		t.server.resetCursorMode()
	}
	if idx := slices.Index(t.server.topLevels, t); idx != -1 {
		t.server.topLevels = slices.Delete(t.server.topLevels, idx, idx+1)
	}
}

//export display_xdg_toplevel_commit
func display_xdg_toplevel_commit(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.commit))
	if t.toplevel.base.initial_commit {
		C.wlr_xdg_toplevel_set_size(t.toplevel, 0, 0)
	}
}

//export display_xdg_toplevel_destroy
func display_xdg_toplevel_destroy(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.destroy))

	C.wl_list_remove(&t.mmap.link)
	C.wl_list_remove(&t.unmap.link)
	C.wl_list_remove(&t.commit.link)
	C.wl_list_remove(&t.destroy.link)
	C.wl_list_remove(&t.requestMove.link)
	C.wl_list_remove(&t.requestResize.link)
	C.wl_list_remove(&t.requestMaximize.link)
	C.wl_list_remove(&t.requestFullscreen.link)

}

//export display_xdg_toplevel_request_move
func display_xdg_toplevel_request_move(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.requestMove))
	t.server.beginInteractive(t, CursorModeMove, 0)
}

//export display_xdg_toplevel_request_resize
func display_xdg_toplevel_request_resize(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.requestResize))
	event := (*C.struct_wlr_xdg_toplevel_resize_event)(data)

	t.server.beginInteractive(t, CursorModeResize, event.edges)
}

//export display_xdg_toplevel_request_maximize
func display_xdg_toplevel_request_maximize(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.requestMaximize))
	if t.toplevel.base.initialized {
		C.wlr_xdg_surface_schedule_configure(t.toplevel.base)
	}
}

//export display_xdg_toplevel_request_fullscreen
func display_xdg_toplevel_request_fullscreen(listener *C.struct_wl_listener, data unsafe.Pointer) {
	t := containerOf[Toplevel](listener, unsafe.Offsetof(Toplevel{}.requestFullscreen))
	if t.toplevel.base.initialized {
		C.wlr_xdg_surface_schedule_configure(t.toplevel.base)
	}
}

//export display_xdg_popup_commit
func display_xdg_popup_commit(listener *C.struct_wl_listener, data unsafe.Pointer) {
	p := containerOf[Popup](listener, unsafe.Offsetof(Popup{}.commit))

	if p.backend.base.initial_commit {
		C.wlr_xdg_surface_schedule_configure(p.backend.base)
	}
}

//export display_xdg_popup_destroy
func display_xdg_popup_destroy(listener *C.struct_wl_listener, data unsafe.Pointer) {
	p := containerOf[Popup](listener, unsafe.Offsetof(Popup{}.destroy))
	C.wl_list_remove(&p.commit.link)
	C.wl_list_remove(&p.destroy.link)
}

//export display_layer_surface_destroy
func display_layer_surface_destroy(listener *C.struct_wl_listener, data unsafe.Pointer) {
	C.wl_list_remove(&listener.link)
}

//export display_new_layer_surface
func display_new_layer_surface(listener *C.struct_wl_listener, data unsafe.Pointer) {
	s := containerOf[Server](listener, unsafe.Offsetof(Server{}.newLayerSurface))
	layerSurface := (*C.struct_wlr_layer_surface_v1)(data)

	sceneTree := C.wlr_scene_layer_surface_v1_create(&s.scene.tree, layerSurface)
	if sceneTree == nil {
		log.Printf("failed to create scene node for layer surface")
		return
	}

	if layerSurface.surface != nil && layerSurface.initial_commit {
		C.wlr_layer_surface_v1_configure(layerSurface,
			layerSurface.pending.desired_width,
			layerSurface.pending.desired_height)
	}

	var destroy C.struct_wl_listener
	destroy.notify = (*[0]byte)(C.display_layer_surface_destroy)
	C.wl_signal_add(&layerSurface.events.destroy, &destroy)
}
