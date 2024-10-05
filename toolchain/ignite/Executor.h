#ifndef PKGUPD_EXEC_H
#define PKGUPD_EXEC_H

#include "Container.h"
#include <array>
#include <optional>
#include <ostream>
#include <string>
#include <sys/wait.h>
#include <utility>
#include <vector>

class Executor {

    std::vector<std::string> args_;
    std::optional<std::string> path_{};
    std::vector<std::string> environ_;
    pid_t pid = -1;
    int pipe_fd[2]{};
    std::ostream* logger_{nullptr};
    bool silent_{false};

public:
    explicit Executor(const std::string& binary) { args_.push_back(binary); }

    Executor& container(const Container* container) {
        if (container != nullptr) {
            std::string path = path_ ? *path_ : "/";
            auto a = container->args();
            a.insert(a.end(), {"--chdir", path});
            args_.insert(args_.begin(), a.begin(), a.end());
            path_.reset();
            logger_ = container->logger;
        }
        return *this;
    }

    Executor& arg(const std::string& a) {
        args_.emplace_back(a);
        return *this;
    }

    Executor& path(const std::string& p) {
        path_ = p;
        return *this;
    }

    Executor& silent() {
        silent_ = true;
        return *this;
    }

    Executor& environ(const std::string& env) {
        environ_.push_back(env);
        return *this;
    }

    Executor& environ(const std::vector<std::string>& env) {
        environ_.insert(environ_.end(), env.begin(), env.end());
        return *this;
    }

    Executor& start();

    int wait(std::ostream* out = nullptr);

    int run();

    void execute();

    void dump_command(std::ostream& os);

    std::tuple<int, std::string> output();
};

#endif
