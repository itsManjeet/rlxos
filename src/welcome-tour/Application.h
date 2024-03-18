/*
 * Copyright (c) 2024 Manjeet Singh <itsmanjeet1998@gmail.com>.
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

#ifndef RLXOS_APPLICATION_H
#define RLXOS_APPLICATION_H

#include <gtkmm.h>

class Window;

class Application : public Gtk::Application {
public:
    static Glib::RefPtr<Application> create();

    ~Application() override;

    void on_activate() override;

    void on_startup() override;

    void on_hide_window(Gtk::Window *window);

    Window *create_window();

private:
    Application();
};


#endif //RLXOS_APPLICATION_H
