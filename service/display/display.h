/*
 * Copyright (c) 2025 Manjeet Singh <itsmanjeet1998@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <assert.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <wayland-server-core.h>
#include <wlr/backend.h>
#include <wlr/render/allocator.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_cursor.h>
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
#include <wlr/util/log.h>
#include <xkbcommon/xkbcommon.h>

#ifndef DEFAULT_TERMINAL
#    define DEFAULT_TERMINAL "/bin/foot"
#endif

enum display_cursor_mode {
    DISPLAY_CURSOR_PASSTHROUGH,
    DISPLAY_CURSOR_MOVE,
    DISPLAY_CURSOR_RESIZE,
};

struct display_server {
    struct wl_display* wl_display;
    struct wlr_backend* backend;
    struct wlr_renderer* renderer;
    struct wlr_allocator* allocator;
    struct wlr_scene* scene;
    struct wlr_scene_output_layout* scene_layout;

    struct wlr_xdg_shell* xdg_shell;
    struct wl_listener new_xdg_toplevel;
    struct wl_listener new_xdg_popup;
    struct wl_list toplevels;

    struct wlr_cursor* cursor;
    struct wlr_xcursor_manager* cursor_mgr;
    struct wl_listener cursor_motion;
    struct wl_listener cursor_motion_absolute;
    struct wl_listener cursor_button;
    struct wl_listener cursor_axis;
    struct wl_listener cursor_frame;

    struct wlr_seat* seat;
    struct wl_listener new_input;
    struct wl_listener request_cursor;
    struct wl_listener request_set_selection;
    struct wl_list keyboards;
    enum display_cursor_mode cursor_mode;
    struct display_toplevel* grabbed_toplevel;
    double grab_x, grab_y;
    struct wlr_box grab_geobox;
    uint32_t resize_edges;

    struct wlr_output_layout* output_layout;
    struct wl_list outputs;
    struct wl_listener new_output;
};

struct display_output {
    struct wl_list link;
    struct display_server* server;
    struct wlr_output* wlr_output;
    struct wl_listener frame;
    struct wl_listener request_state;
    struct wl_listener destroy;
};

struct display_toplevel {
    struct wl_list link;
    struct display_server* server;
    struct wlr_xdg_toplevel* xdg_toplevel;
    struct wlr_scene_tree* scene_tree;
    struct wl_listener map;
    struct wl_listener unmap;
    struct wl_listener commit;
    struct wl_listener destroy;
    struct wl_listener request_move;
    struct wl_listener request_resize;
    struct wl_listener request_maximize;
    struct wl_listener request_fullscreen;
};

struct display_popup {
    struct wlr_xdg_popup* xdg_popup;
    struct wl_listener commit;
    struct wl_listener destroy;
};

struct display_keyboard {
    struct wl_list link;
    struct display_server* server;
    struct wlr_keyboard* wlr_keyboard;

    struct wl_listener modifiers;
    struct wl_listener key;
    struct wl_listener destroy;
};

static void focus_toplevel(
        struct display_toplevel* toplevel, struct wlr_surface* surface) {

    if (toplevel == NULL) { return; }
    struct display_server* server = toplevel->server;
    struct wlr_seat* seat = server->seat;
    struct wlr_surface* prev_surface = seat->keyboard_state.focused_surface;
    if (prev_surface == surface) { return; }
    if (prev_surface) {

        struct wlr_xdg_toplevel* prev_toplevel =
                wlr_xdg_toplevel_try_from_wlr_surface(prev_surface);
        if (prev_toplevel != NULL) {
            wlr_xdg_toplevel_set_activated(prev_toplevel, false);
        }
    }
    struct wlr_keyboard* keyboard = wlr_seat_get_keyboard(seat);

    wlr_scene_node_raise_to_top(&toplevel->scene_tree->node);
    wl_list_remove(&toplevel->link);
    wl_list_insert(&server->toplevels, &toplevel->link);

    wlr_xdg_toplevel_set_activated(toplevel->xdg_toplevel, true);

    if (keyboard != NULL) {
        wlr_seat_keyboard_notify_enter(seat,
                toplevel->xdg_toplevel->base->surface, keyboard->keycodes,
                keyboard->num_keycodes, &keyboard->modifiers);
    }
}

static void keyboard_handle_modifiers(
        struct wl_listener* listener, void* data) {

    struct display_keyboard* keyboard =
            wl_container_of(listener, keyboard, modifiers);

    wlr_seat_set_keyboard(keyboard->server->seat, keyboard->wlr_keyboard);

    wlr_seat_keyboard_notify_modifiers(
            keyboard->server->seat, &keyboard->wlr_keyboard->modifiers);
}

static void spawn(const char* cmd) {
    if (fork() == 0) {
        dup2(STDOUT_FILENO, STDERR_FILENO);
        setsid();
        execl(cmd, cmd, NULL);
        exit(EXIT_FAILURE);
    }
}

static bool handle_keybinding(struct display_server* server, xkb_keysym_t sym) {

    switch (sym) {
    case XKB_KEY_Escape: wl_display_terminate(server->wl_display); break;
    case XKB_KEY_F1:

        if (wl_list_length(&server->toplevels) < 2) { break; }
        struct display_toplevel* next_toplevel =
                wl_container_of(server->toplevels.prev, next_toplevel, link);
        focus_toplevel(
                next_toplevel, next_toplevel->xdg_toplevel->base->surface);
        break;
    case XKB_KEY_Return: spawn(DEFAULT_TERMINAL);
    default: return false;
    }
    return true;
}

static void keyboard_handle_key(struct wl_listener* listener, void* data) {

    struct display_keyboard* keyboard =
            wl_container_of(listener, keyboard, key);
    struct display_server* server = keyboard->server;
    struct wlr_keyboard_key_event* event = data;
    struct wlr_seat* seat = server->seat;

    uint32_t keycode = event->keycode + 8;

    const xkb_keysym_t* syms;
    int nsyms = xkb_state_key_get_syms(
            keyboard->wlr_keyboard->xkb_state, keycode, &syms);

    bool handled = false;
    uint32_t modifiers = wlr_keyboard_get_modifiers(keyboard->wlr_keyboard);
    if ((modifiers & WLR_MODIFIER_ALT) &&
            event->state == WL_KEYBOARD_KEY_STATE_PRESSED) {

        for (int i = 0; i < nsyms; i++) {
            handled = handle_keybinding(server, syms[i]);
        }
    }

    if (!handled) {

        wlr_seat_set_keyboard(seat, keyboard->wlr_keyboard);
        wlr_seat_keyboard_notify_key(
                seat, event->time_msec, event->keycode, event->state);
    }
}

static void keyboard_handle_destroy(struct wl_listener* listener, void* data) {

    struct display_keyboard* keyboard =
            wl_container_of(listener, keyboard, destroy);
    wl_list_remove(&keyboard->modifiers.link);
    wl_list_remove(&keyboard->key.link);
    wl_list_remove(&keyboard->destroy.link);
    wl_list_remove(&keyboard->link);
    free(keyboard);
}

static void server_new_keyboard(
        struct display_server* server, struct wlr_input_device* device) {
    struct wlr_keyboard* wlr_keyboard = wlr_keyboard_from_input_device(device);

    struct display_keyboard* keyboard = calloc(1, sizeof(*keyboard));
    keyboard->server = server;
    keyboard->wlr_keyboard = wlr_keyboard;

    struct xkb_context* context = xkb_context_new(XKB_CONTEXT_NO_FLAGS);
    struct xkb_keymap* keymap = xkb_keymap_new_from_names(
            context, NULL, XKB_KEYMAP_COMPILE_NO_FLAGS);

    wlr_keyboard_set_keymap(wlr_keyboard, keymap);
    xkb_keymap_unref(keymap);
    xkb_context_unref(context);
    wlr_keyboard_set_repeat_info(wlr_keyboard, 25, 600);

    keyboard->modifiers.notify = keyboard_handle_modifiers;
    wl_signal_add(&wlr_keyboard->events.modifiers, &keyboard->modifiers);
    keyboard->key.notify = keyboard_handle_key;
    wl_signal_add(&wlr_keyboard->events.key, &keyboard->key);
    keyboard->destroy.notify = keyboard_handle_destroy;
    wl_signal_add(&device->events.destroy, &keyboard->destroy);

    wlr_seat_set_keyboard(server->seat, keyboard->wlr_keyboard);

    wl_list_insert(&server->keyboards, &keyboard->link);
}

static void server_new_pointer(
        struct display_server* server, struct wlr_input_device* device) {

    wlr_cursor_attach_input_device(server->cursor, device);
}

static void server_new_input(struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, new_input);
    struct wlr_input_device* device = data;
    switch (device->type) {
    case WLR_INPUT_DEVICE_KEYBOARD: server_new_keyboard(server, device); break;
    case WLR_INPUT_DEVICE_POINTER: server_new_pointer(server, device); break;
    default: break;
    }

    uint32_t caps = WL_SEAT_CAPABILITY_POINTER;
    if (!wl_list_empty(&server->keyboards)) {
        caps |= WL_SEAT_CAPABILITY_KEYBOARD;
    }
    wlr_seat_set_capabilities(server->seat, caps);
}

static void seat_request_cursor(struct wl_listener* listener, void* data) {
    struct display_server* server =
            wl_container_of(listener, server, request_cursor);

    struct wlr_seat_pointer_request_set_cursor_event* event = data;
    struct wlr_seat_client* focused_client =
            server->seat->pointer_state.focused_client;

    if (focused_client == event->seat_client) {

        wlr_cursor_set_surface(server->cursor, event->surface, event->hotspot_x,
                event->hotspot_y);
    }
}

static void seat_request_set_selection(
        struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, request_set_selection);
    struct wlr_seat_request_set_selection_event* event = data;
    wlr_seat_set_selection(server->seat, event->source, event->serial);
}

static struct display_toplevel* desktop_toplevel_at(
        struct display_server* server, double lx, double ly,
        struct wlr_surface** surface, double* sx, double* sy) {

    struct wlr_scene_node* node =
            wlr_scene_node_at(&server->scene->tree.node, lx, ly, sx, sy);
    if (node == NULL || node->type != WLR_SCENE_NODE_BUFFER) { return NULL; }
    struct wlr_scene_buffer* scene_buffer = wlr_scene_buffer_from_node(node);
    struct wlr_scene_surface* scene_surface =
            wlr_scene_surface_try_from_buffer(scene_buffer);
    if (!scene_surface) { return NULL; }

    *surface = scene_surface->surface;

    struct wlr_scene_tree* tree = node->parent;
    while (tree != NULL && tree->node.data == NULL) {
        tree = tree->node.parent;
    }
    return tree->node.data;
}

static void reset_cursor_mode(struct display_server* server) {

    server->cursor_mode = DISPLAY_CURSOR_PASSTHROUGH;
    server->grabbed_toplevel = NULL;
}

static void process_cursor_move(struct display_server* server, uint32_t time) {

    struct display_toplevel* toplevel = server->grabbed_toplevel;
    wlr_scene_node_set_position(&toplevel->scene_tree->node,
            server->cursor->x - server->grab_x,
            server->cursor->y - server->grab_y);
}

static void process_cursor_resize(
        struct display_server* server, uint32_t time) {

    struct display_toplevel* toplevel = server->grabbed_toplevel;
    double border_x = server->cursor->x - server->grab_x;
    double border_y = server->cursor->y - server->grab_y;
    int new_left = server->grab_geobox.x;
    int new_right = server->grab_geobox.x + server->grab_geobox.width;
    int new_top = server->grab_geobox.y;
    int new_bottom = server->grab_geobox.y + server->grab_geobox.height;

    if (server->resize_edges & WLR_EDGE_TOP) {
        new_top = border_y;
        if (new_top >= new_bottom) { new_top = new_bottom - 1; }
    } else if (server->resize_edges & WLR_EDGE_BOTTOM) {
        new_bottom = border_y;
        if (new_bottom <= new_top) { new_bottom = new_top + 1; }
    }
    if (server->resize_edges & WLR_EDGE_LEFT) {
        new_left = border_x;
        if (new_left >= new_right) { new_left = new_right - 1; }
    } else if (server->resize_edges & WLR_EDGE_RIGHT) {
        new_right = border_x;
        if (new_right <= new_left) { new_right = new_left + 1; }
    }

    struct wlr_box geo_box;
    wlr_xdg_surface_get_geometry(toplevel->xdg_toplevel->base, &geo_box);
    wlr_scene_node_set_position(&toplevel->scene_tree->node,
            new_left - geo_box.x, new_top - geo_box.y);

    int new_width = new_right - new_left;
    int new_height = new_bottom - new_top;
    wlr_xdg_toplevel_set_size(toplevel->xdg_toplevel, new_width, new_height);
}

static void process_cursor_motion(
        struct display_server* server, uint32_t time) {

    if (server->cursor_mode == DISPLAY_CURSOR_MOVE) {
        process_cursor_move(server, time);
        return;
    } else if (server->cursor_mode == DISPLAY_CURSOR_RESIZE) {
        process_cursor_resize(server, time);
        return;
    }

    double sx, sy;
    struct wlr_seat* seat = server->seat;
    struct wlr_surface* surface = NULL;
    struct display_toplevel* toplevel = desktop_toplevel_at(
            server, server->cursor->x, server->cursor->y, &surface, &sx, &sy);
    if (!toplevel) {

        wlr_cursor_set_xcursor(server->cursor, server->cursor_mgr, "default");
    }
    if (surface) {

        wlr_seat_pointer_notify_enter(seat, surface, sx, sy);
        wlr_seat_pointer_notify_motion(seat, time, sx, sy);
    } else {

        wlr_seat_pointer_clear_focus(seat);
    }
}

static void server_cursor_motion(struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, cursor_motion);
    struct wlr_pointer_motion_event* event = data;

    wlr_cursor_move(server->cursor, &event->pointer->base, event->delta_x,
            event->delta_y);
    process_cursor_motion(server, event->time_msec);
}

static void server_cursor_motion_absolute(
        struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, cursor_motion_absolute);
    struct wlr_pointer_motion_absolute_event* event = data;
    wlr_cursor_warp_absolute(
            server->cursor, &event->pointer->base, event->x, event->y);
    process_cursor_motion(server, event->time_msec);
}

static void server_cursor_button(struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, cursor_button);
    struct wlr_pointer_button_event* event = data;

    wlr_seat_pointer_notify_button(
            server->seat, event->time_msec, event->button, event->state);
    double sx, sy;
    struct wlr_surface* surface = NULL;
    struct display_toplevel* toplevel = desktop_toplevel_at(
            server, server->cursor->x, server->cursor->y, &surface, &sx, &sy);
    if (event->state == WL_POINTER_BUTTON_STATE_RELEASED) {

        reset_cursor_mode(server);
    } else {

        focus_toplevel(toplevel, surface);
    }
}

static void server_cursor_axis(struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, cursor_axis);
    struct wlr_pointer_axis_event* event = data;

    wlr_seat_pointer_notify_axis(server->seat, event->time_msec,
            event->orientation, event->delta, event->delta_discrete,
            event->source, event->relative_direction);
}

static void server_cursor_frame(struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, cursor_frame);

    wlr_seat_pointer_notify_frame(server->seat);
}

static void output_frame(struct wl_listener* listener, void* data) {

    struct display_output* output = wl_container_of(listener, output, frame);
    struct wlr_scene* scene = output->server->scene;

    struct wlr_scene_output* scene_output =
            wlr_scene_get_scene_output(scene, output->wlr_output);

    wlr_scene_output_commit(scene_output, NULL);

    struct timespec now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    wlr_scene_output_send_frame_done(scene_output, &now);
}

static void output_request_state(struct wl_listener* listener, void* data) {

    struct display_output* output =
            wl_container_of(listener, output, request_state);
    const struct wlr_output_event_request_state* event = data;
    wlr_output_commit_state(output->wlr_output, event->state);
}

static void output_destroy(struct wl_listener* listener, void* data) {
    struct display_output* output = wl_container_of(listener, output, destroy);

    wl_list_remove(&output->frame.link);
    wl_list_remove(&output->request_state.link);
    wl_list_remove(&output->destroy.link);
    wl_list_remove(&output->link);
    free(output);
}

static void server_new_output(struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, new_output);
    struct wlr_output* wlr_output = data;

    wlr_output_init_render(wlr_output, server->allocator, server->renderer);

    struct wlr_output_state state;
    wlr_output_state_init(&state);
    wlr_output_state_set_enabled(&state, true);

    struct wlr_output_mode* mode = wlr_output_preferred_mode(wlr_output);
    if (mode != NULL) { wlr_output_state_set_mode(&state, mode); }

    wlr_output_commit_state(wlr_output, &state);
    wlr_output_state_finish(&state);

    struct display_output* output = calloc(1, sizeof(*output));
    output->wlr_output = wlr_output;
    output->server = server;

    output->frame.notify = output_frame;
    wl_signal_add(&wlr_output->events.frame, &output->frame);

    output->request_state.notify = output_request_state;
    wl_signal_add(&wlr_output->events.request_state, &output->request_state);

    output->destroy.notify = output_destroy;
    wl_signal_add(&wlr_output->events.destroy, &output->destroy);

    wl_list_insert(&server->outputs, &output->link);

    struct wlr_output_layout_output* l_output =
            wlr_output_layout_add_auto(server->output_layout, wlr_output);
    struct wlr_scene_output* scene_output =
            wlr_scene_output_create(server->scene, wlr_output);
    wlr_scene_output_layout_add_output(
            server->scene_layout, l_output, scene_output);
}

static void xdg_toplevel_map(struct wl_listener* listener, void* data) {

    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, map);

    wl_list_insert(&toplevel->server->toplevels, &toplevel->link);

    focus_toplevel(toplevel, toplevel->xdg_toplevel->base->surface);
}

static void xdg_toplevel_unmap(struct wl_listener* listener, void* data) {

    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, unmap);

    if (toplevel == toplevel->server->grabbed_toplevel) {
        reset_cursor_mode(toplevel->server);
    }

    wl_list_remove(&toplevel->link);
}

static void xdg_toplevel_commit(struct wl_listener* listener, void* data) {

    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, commit);

    if (toplevel->xdg_toplevel->base->initial_commit) {

        wlr_xdg_toplevel_set_size(toplevel->xdg_toplevel, 0, 0);
    }
}

static void xdg_toplevel_destroy(struct wl_listener* listener, void* data) {

    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, destroy);

    wl_list_remove(&toplevel->map.link);
    wl_list_remove(&toplevel->unmap.link);
    wl_list_remove(&toplevel->commit.link);
    wl_list_remove(&toplevel->destroy.link);
    wl_list_remove(&toplevel->request_move.link);
    wl_list_remove(&toplevel->request_resize.link);
    wl_list_remove(&toplevel->request_maximize.link);
    wl_list_remove(&toplevel->request_fullscreen.link);

    free(toplevel);
}

static void begin_interactive(struct display_toplevel* toplevel,
        enum display_cursor_mode mode, uint32_t edges) {

    struct display_server* server = toplevel->server;
    struct wlr_surface* focused_surface =
            server->seat->pointer_state.focused_surface;
    if (toplevel->xdg_toplevel->base->surface !=
            wlr_surface_get_root_surface(focused_surface)) {

        return;
    }
    server->grabbed_toplevel = toplevel;
    server->cursor_mode = mode;

    if (mode == DISPLAY_CURSOR_MOVE) {
        server->grab_x = server->cursor->x - toplevel->scene_tree->node.x;
        server->grab_y = server->cursor->y - toplevel->scene_tree->node.y;
    } else {
        struct wlr_box geo_box;
        wlr_xdg_surface_get_geometry(toplevel->xdg_toplevel->base, &geo_box);

        double border_x = (toplevel->scene_tree->node.x + geo_box.x) +
                          ((edges & WLR_EDGE_RIGHT) ? geo_box.width : 0);
        double border_y = (toplevel->scene_tree->node.y + geo_box.y) +
                          ((edges & WLR_EDGE_BOTTOM) ? geo_box.height : 0);
        server->grab_x = server->cursor->x - border_x;
        server->grab_y = server->cursor->y - border_y;

        server->grab_geobox = geo_box;
        server->grab_geobox.x += toplevel->scene_tree->node.x;
        server->grab_geobox.y += toplevel->scene_tree->node.y;

        server->resize_edges = edges;
    }
}

static void xdg_toplevel_request_move(
        struct wl_listener* listener, void* data) {

    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, request_move);
    begin_interactive(toplevel, DISPLAY_CURSOR_MOVE, 0);
}

static void xdg_toplevel_request_resize(
        struct wl_listener* listener, void* data) {

    struct wlr_xdg_toplevel_resize_event* event = data;
    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, request_resize);
    begin_interactive(toplevel, DISPLAY_CURSOR_RESIZE, event->edges);
}

static void xdg_toplevel_request_maximize(
        struct wl_listener* listener, void* data) {

    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, request_maximize);
    if (toplevel->xdg_toplevel->base->initialized) {
        wlr_xdg_surface_schedule_configure(toplevel->xdg_toplevel->base);
    }
}

static void xdg_toplevel_request_fullscreen(
        struct wl_listener* listener, void* data) {

    struct display_toplevel* toplevel =
            wl_container_of(listener, toplevel, request_fullscreen);
    if (toplevel->xdg_toplevel->base->initialized) {
        wlr_xdg_surface_schedule_configure(toplevel->xdg_toplevel->base);
    }
}

static void server_new_xdg_toplevel(struct wl_listener* listener, void* data) {

    struct display_server* server =
            wl_container_of(listener, server, new_xdg_toplevel);
    struct wlr_xdg_toplevel* xdg_toplevel = data;

    struct display_toplevel* toplevel = calloc(1, sizeof(*toplevel));
    toplevel->server = server;
    toplevel->xdg_toplevel = xdg_toplevel;
    toplevel->scene_tree = wlr_scene_xdg_surface_create(
            &toplevel->server->scene->tree, xdg_toplevel->base);
    toplevel->scene_tree->node.data = toplevel;
    xdg_toplevel->base->data = toplevel->scene_tree;

    toplevel->map.notify = xdg_toplevel_map;
    wl_signal_add(&xdg_toplevel->base->surface->events.map, &toplevel->map);
    toplevel->unmap.notify = xdg_toplevel_unmap;
    wl_signal_add(&xdg_toplevel->base->surface->events.unmap, &toplevel->unmap);
    toplevel->commit.notify = xdg_toplevel_commit;
    wl_signal_add(
            &xdg_toplevel->base->surface->events.commit, &toplevel->commit);

    toplevel->destroy.notify = xdg_toplevel_destroy;
    wl_signal_add(&xdg_toplevel->events.destroy, &toplevel->destroy);

    toplevel->request_move.notify = xdg_toplevel_request_move;
    wl_signal_add(&xdg_toplevel->events.request_move, &toplevel->request_move);
    toplevel->request_resize.notify = xdg_toplevel_request_resize;
    wl_signal_add(
            &xdg_toplevel->events.request_resize, &toplevel->request_resize);
    toplevel->request_maximize.notify = xdg_toplevel_request_maximize;
    wl_signal_add(&xdg_toplevel->events.request_maximize,
            &toplevel->request_maximize);
    toplevel->request_fullscreen.notify = xdg_toplevel_request_fullscreen;
    wl_signal_add(&xdg_toplevel->events.request_fullscreen,
            &toplevel->request_fullscreen);
}

static void xdg_popup_commit(struct wl_listener* listener, void* data) {

    struct display_popup* popup = wl_container_of(listener, popup, commit);

    if (popup->xdg_popup->base->initial_commit) {

        wlr_xdg_surface_schedule_configure(popup->xdg_popup->base);
    }
}

static void xdg_popup_destroy(struct wl_listener* listener, void* data) {

    struct display_popup* popup = wl_container_of(listener, popup, destroy);

    wl_list_remove(&popup->commit.link);
    wl_list_remove(&popup->destroy.link);

    free(popup);
}

static void server_new_xdg_popup(struct wl_listener* listener, void* data) {

    struct wlr_xdg_popup* xdg_popup = data;

    struct display_popup* popup = calloc(1, sizeof(*popup));
    popup->xdg_popup = xdg_popup;

    struct wlr_xdg_surface* parent =
            wlr_xdg_surface_try_from_wlr_surface(xdg_popup->parent);
    assert(parent != NULL);
    struct wlr_scene_tree* parent_tree = parent->data;
    xdg_popup->base->data =
            wlr_scene_xdg_surface_create(parent_tree, xdg_popup->base);

    popup->commit.notify = xdg_popup_commit;
    wl_signal_add(&xdg_popup->base->surface->events.commit, &popup->commit);

    popup->destroy.notify = xdg_popup_destroy;
    wl_signal_add(&xdg_popup->events.destroy, &popup->destroy);
}

int start_display_backend() {
    wlr_log_init(WLR_DEBUG, NULL);

    struct display_server server = {0};

    server.wl_display = wl_display_create();

    server.backend = wlr_backend_autocreate(
            wl_display_get_event_loop(server.wl_display), NULL);
    if (server.backend == NULL) {
        wlr_log(WLR_ERROR, "failed to create wlr_backend");
        return 1;
    }

    server.renderer = wlr_renderer_autocreate(server.backend);
    if (server.renderer == NULL) {
        wlr_log(WLR_ERROR, "failed to create wlr_renderer");
        return 1;
    }

    wlr_renderer_init_wl_display(server.renderer, server.wl_display);

    server.allocator =
            wlr_allocator_autocreate(server.backend, server.renderer);
    if (server.allocator == NULL) {
        wlr_log(WLR_ERROR, "failed to create wlr_allocator");
        return 1;
    }

    wlr_compositor_create(server.wl_display, 5, server.renderer);
    wlr_subcompositor_create(server.wl_display);
    wlr_data_device_manager_create(server.wl_display);

    server.output_layout = wlr_output_layout_create(server.wl_display);

    wl_list_init(&server.outputs);
    server.new_output.notify = server_new_output;
    wl_signal_add(&server.backend->events.new_output, &server.new_output);

    server.scene = wlr_scene_create();
    server.scene_layout =
            wlr_scene_attach_output_layout(server.scene, server.output_layout);

    wl_list_init(&server.toplevels);
    server.xdg_shell = wlr_xdg_shell_create(server.wl_display, 3);
    server.new_xdg_toplevel.notify = server_new_xdg_toplevel;
    wl_signal_add(
            &server.xdg_shell->events.new_toplevel, &server.new_xdg_toplevel);
    server.new_xdg_popup.notify = server_new_xdg_popup;
    wl_signal_add(&server.xdg_shell->events.new_popup, &server.new_xdg_popup);

    server.cursor = wlr_cursor_create();
    wlr_cursor_attach_output_layout(server.cursor, server.output_layout);

    server.cursor_mgr = wlr_xcursor_manager_create(NULL, 24);

    server.cursor_mode = DISPLAY_CURSOR_PASSTHROUGH;
    server.cursor_motion.notify = server_cursor_motion;
    wl_signal_add(&server.cursor->events.motion, &server.cursor_motion);
    server.cursor_motion_absolute.notify = server_cursor_motion_absolute;
    wl_signal_add(&server.cursor->events.motion_absolute,
            &server.cursor_motion_absolute);
    server.cursor_button.notify = server_cursor_button;
    wl_signal_add(&server.cursor->events.button, &server.cursor_button);
    server.cursor_axis.notify = server_cursor_axis;
    wl_signal_add(&server.cursor->events.axis, &server.cursor_axis);
    server.cursor_frame.notify = server_cursor_frame;
    wl_signal_add(&server.cursor->events.frame, &server.cursor_frame);

    wl_list_init(&server.keyboards);
    server.new_input.notify = server_new_input;
    wl_signal_add(&server.backend->events.new_input, &server.new_input);
    server.seat = wlr_seat_create(server.wl_display, "seat0");
    server.request_cursor.notify = seat_request_cursor;
    wl_signal_add(
            &server.seat->events.request_set_cursor, &server.request_cursor);
    server.request_set_selection.notify = seat_request_set_selection;
    wl_signal_add(&server.seat->events.request_set_selection,
            &server.request_set_selection);

    const char* socket = wl_display_add_socket_auto(server.wl_display);
    if (!socket) {
        wlr_backend_destroy(server.backend);
        return 1;
    }

    if (!wlr_backend_start(server.backend)) {
        wlr_backend_destroy(server.backend);
        wl_display_destroy(server.wl_display);
        return 1;
    }

    setenv("WAYLAND_DISPLAY", socket, true);

    wlr_log(WLR_INFO, "Running Wayland compositor on WAYLAND_DISPLAY=%s",
            socket);
    wl_display_run(server.wl_display);

    wl_display_destroy_clients(server.wl_display);
    wlr_scene_node_destroy(&server.scene->tree.node);
    wlr_xcursor_manager_destroy(server.cursor_mgr);
    wlr_cursor_destroy(server.cursor);
    wlr_allocator_destroy(server.allocator);
    wlr_renderer_destroy(server.renderer);
    wlr_backend_destroy(server.backend);
    wl_display_destroy(server.wl_display);
    return 0;
}
