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

#include "Application.h"
#include "Window.h"

#include <iostream>

Application::Application() : Gtk::Application("dev.rlxos.WelcomeTour") {

}

Application::~Application() = default;

Glib::RefPtr<Application> Application::create() {
    return Glib::RefPtr<Application>(new Application());
}

Window *Application::create_window() {
    if (get_windows().empty()) {
        auto window = Window::create();
        add_window(*window);
    }
    auto window = get_windows().front();
    window->signal_hide().connect(sigc::bind(sigc::mem_fun(*this, &Application::on_hide_window), window));
    return dynamic_cast<Window *>(window);
}

void Application::on_activate() {
    try {
        auto window = create_window();
        window->present();
    } catch (const Glib::Error &error) {
        std::cerr << "Application::on_activate(): " << error.what() << std::endl;
    } catch (const std::exception &error) {
        std::cerr << "Application::on_activate(): " << error.what() << std::endl;
    }
}

void Application::on_startup() {
    Gtk::Application::on_startup();
}

void Application::on_hide_window(Gtk::Window *window) {
    quit();
}