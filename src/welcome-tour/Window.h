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

#ifndef RLXOS_WINDOW_H
#define RLXOS_WINDOW_H

#include <gtkmm.h>

class Window : public Gtk::ApplicationWindow {
public:
    Window(Gtk::ApplicationWindow::BaseObjectType *object, const Glib::RefPtr<Gtk::Builder> &builder);

    ~Window() override;

    static Window *create();

protected:
    void on_next_btn_clicked();

    void on_back_btn_clicked();

    void on_exit_btn_clicked();

private:
    Gtk::Button *back_btn{}, *next_btn{}, *exit_btn{};
    Gtk::Stack *stack{};
    Gtk::Label *welcome_heading{}, *welcome_message{};
    std::string name;
    std::string version;

    void update_buttons();
};


#endif //RLXOS_WINDOW_H
