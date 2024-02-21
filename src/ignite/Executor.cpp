/*
 * Copyright (c) 2023 Manjeet Singh <itsmanjeet1998@gmail.com>.
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

#include "Executor.h"

#include <cstring>
#include <sstream>

enum {
    READ = 0, WRITE = 1
};

Executor &Executor::start() {
    if (pipe(pipe_fd) == -1) {
        throw std::runtime_error("pipe creating failed");
    }

    pid = fork();
    if (pid == -1) {
        throw std::runtime_error("failed to fork new process");
    } else if (pid == 0) {
        close(pipe_fd[READ]);

        dup2(pipe_fd[WRITE], STDOUT_FILENO);
        dup2(pipe_fd[WRITE], STDERR_FILENO);

        close(pipe_fd[WRITE]);

        if (path_)
            if (chdir(path_->c_str()) == -1)
                throw std::runtime_error("failed to switch path to " + *path_);
        clearenv();

        std::vector<const char *> args;
        for (auto const &c: args_) args.emplace_back(c.c_str());
        args.push_back(nullptr);

        std::vector<const char *> env;
        for (auto const &c: environ_) env.emplace_back(c.c_str());
        env.push_back(nullptr);

        if (execve(args_[0].c_str(), (char *const *) args.data(), (char *const *) env.data()) == -1) {
            perror("execution failed");
        }
        exit(EXIT_FAILURE);
    }
    return *this;
}

int Executor::wait(std::ostream *out) {
    close(pipe_fd[WRITE]);

    char buffer[BUFSIZ] = {0};
    ssize_t bytes_read;
    while ((bytes_read = read(pipe_fd[READ], buffer, sizeof(buffer))) > 0) {
        if (out) out->write(buffer, bytes_read);
        if (logger_) logger_->write(buffer, bytes_read);
    }

    close(pipe_fd[READ]);
    int status;
    waitpid(pid, &status, 0);

    return WEXITSTATUS(status);
}

int Executor::run() {
    start();
    return wait(silent_ ? nullptr : &std::cout);
}

std::tuple<int, std::string> Executor::output() {
    std::stringstream output;
    start();
    int status = wait(&output);
    std::string output_data = output.str();
    output_data.shrink_to_fit();
    if (output_data.ends_with("\n")) output_data.pop_back();
    return {status, output_data};
}

void Executor::execute() {
    std::stringstream ss;
    for (auto const &a: args_) { ss << a << " "; }
    if (!silent_) {
        DEBUG("COMMAND : " << ss.str());
        DEBUG("PATH    : " << (path_ ? *path_ : "."));

        if (logger_) {
            *logger_ << "COMMAND  : " << ss.str() << std::endl;
            *logger_ << "path     : " << (path_ ? *path_ : ".") << std::endl;
        }
    }

    if (int status = run(); status != 0) {
        throw std::runtime_error("failed to execute command (" + ss.str() + "): exit code " + std::to_string(status));
    }
}
