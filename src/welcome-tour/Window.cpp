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

#include "Window.h"

#include <fstream>
#include <filesystem>

#define OS_RELEASE_FILE "/etc/os-release"

Window::Window(Gtk::ApplicationWindow::BaseObjectType *object, const Glib::RefPtr<Gtk::Builder> &builder)
        : Gtk::ApplicationWindow(object) {
    builder->get_widget("back-button", back_btn);
    back_btn->signal_clicked().connect(sigc::mem_fun(*this, &Window::on_back_btn_clicked));

    builder->get_widget("next-button", next_btn);
    next_btn->signal_clicked().connect(sigc::mem_fun(*this, &Window::on_next_btn_clicked));

    builder->get_widget("exit-button", exit_btn);
    exit_btn->signal_clicked().connect(sigc::mem_fun(*this, &Window::on_exit_btn_clicked));

    builder->get_widget("welcome-heading", welcome_heading);
    builder->get_widget("welcome-message", welcome_message);

    builder->get_widget("stack", stack);


    {
        std::ifstream reader(OS_RELEASE_FILE);
        if (reader.good()) {
            for (std::string line; std::getline(reader, line, '\n');) {
                if ((line.starts_with("NAME=") && name.empty()) || line.starts_with("PRETTY_NAME=")) {
                    name = line.substr(line.find('=') + 1);
                }

                if ((line.starts_with("VERSION=") && version.empty()) || line.starts_with("IMAGE_VERSION=")) {
                    version = line.substr(line.find('=') + 1);
                }
            }
        }
        if (!name.empty()) {
            auto start = name.find_first_not_of('"');
            name = name.substr(start, name.find_last_not_of('"') - start + 1);
        }

        if (!version.empty()) {
            auto start = version.find_first_not_of('"');
            version = version.substr(start, version.find_last_not_of('"') - start + 1);
        }

    }
    if (name.empty()) {
        name = "Linux Distribution";
    }
    welcome_heading->set_text("Welcome to " + name + " " + (version.empty() ? "" : version));

    update_buttons();
}

Window::~Window() = default;

Window *Window::create() {
    auto builder = Gtk::Builder::create_from_resource("/dev/rlxos/WelcomeTour/Window.ui");
    Window *window = nullptr;

    builder->get_widget_derived("window", window);
    if (window == nullptr) {
        throw std::runtime_error("No 'window' object in resource::window.ui");
    }

    return window;
}

void Window::update_buttons() {
    auto cur_page = stack->child_property_position(*stack->get_visible_child()).get_value();
    back_btn->set_sensitive(cur_page != 0);
    next_btn->set_sensitive(cur_page < stack->get_children().size() - 1);
}

void Window::on_next_btn_clicked() {
    stack->set_visible_child(
            *stack->get_children()[stack->child_property_position(*stack->get_visible_child()).get_value() + 1]);
    update_buttons();
}

void Window::on_back_btn_clicked() {
    stack->set_visible_child(
            *stack->get_children()[stack->child_property_position(*stack->get_visible_child()).get_value() - 1]);
    update_buttons();
}

void Window::on_exit_btn_clicked() {
    std::filesystem::path HOME = getenv("HOME") ? getenv("HOME") : "/";
    auto file = HOME / ".welcome-tour-done";

    std::ofstream writer(file);
    writer << version;
    this->get_application()->quit();
}
