#ifndef PKGUPD_ERROR_H
#define PKGUPD_ERROR_H

#include <glib.h>
#include <stdexcept>
#include <utility>

struct Error : std::exception {
    GError* backend{nullptr};
    std::string message;

    explicit Error(GError* error) : backend(error) {}
    explicit Error(std::string mesg) : message{std::move(mesg)} {}
    ~Error() override {
        if (backend != nullptr) g_error_free(backend);
        backend = nullptr;
    }

    [[nodiscard]] const char* what() const noexcept override {
        if (backend)
            return backend->message;
        else
            return message.c_str();
    }
};

#endif