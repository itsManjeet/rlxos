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
#include <filesystem>

int main(int argc, char **argv) {
    std::filesystem::path HOME = getenv("HOME") ? getenv("HOME") : "/";
    auto file = HOME / ".welcome-tour-done";
    if (std::filesystem::exists(file) && getenv("WELCOME_TOUR_AUTOSTART")) return 0;

    auto app = Application::create();
    return app->run(argc, argv);
}