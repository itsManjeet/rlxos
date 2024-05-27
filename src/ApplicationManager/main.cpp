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

#include "ApplicationBundle.h"
#include <common/Application.h>

class ManagerApplication : public Application {
public:
    ManagerApplication() : Application("app", "Application Manager") {
        REGISTER_COMMAND(ManagerApplication, exec, "Run Application", -1);
        REGISTER_COMMAND(ManagerApplication, integrate,
                "Integrate Bundle into system", 1);
        REGISTER_COMMAND(
                ManagerApplication, remove, "Remove Bundle from system", 1);
    }

    void exec() {
        if (ctxt.args.empty()) {
            throw std::runtime_error("no app bundle provided");
        }

        auto appBundle = ApplicationBundle(ctxt.args[0]);
        appBundle.run({ctxt.args.begin() + 1, ctxt.args.end()});
    }

    void integrate() {
        auto appBundle = ApplicationBundle(ctxt.args[0]);
        std::string sysroot = getenv("HOME")
                                      ? std::string(getenv("HOME")) + "/.local"
                                      : "/usr";

        appBundle.integrate(
                ctxt["sysroot"].has_value() ? *ctxt["sysroot"] : sysroot);
    }

    void remove() {
        auto appBundle = ApplicationBundle(ctxt.args[0]);
        std::string sysroot = getenv("HOME")
                                      ? std::string(getenv("HOME")) + "/.local"
                                      : "/usr";

        appBundle.remove(
                ctxt["sysroot"].has_value() ? *ctxt["sysroot"] : sysroot);
    }
};

int main(int argc, char** argv) { return ManagerApplication().run(argc, argv); }