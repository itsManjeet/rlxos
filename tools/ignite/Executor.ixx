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

module;

#include <sys/wait.h>

#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <iostream>
#include <optional>
#include <ostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

export module ignite:Executor;

import :Container;

enum
{
    READ = 0,
    WRITE = 1
};

export auto lookup_exec(const std::string& bin)
    -> std::optional<std::filesystem::path>
{
    auto PATH = getenv("PATH") ? getenv("PATH") : "/bin:/sbin";
    std::stringstream ss(PATH);
    for (std::string path; std::getline(ss, path, ':');)
    {
        auto bin_path = std::filesystem::path(path) / bin;
        if (std::filesystem::exists(bin_path))
        {
            return bin_path;
        }
    }
    return std::nullopt;
}

export class Executor
{
    std::vector<std::string> args_;
    std::optional<std::string> path_{};
    std::vector<std::string> environ_;
    pid_t pid = -1;
    int pipe_fd[2]{};
    std::ostream* logger_{nullptr};
    bool silent_{false};

  public:
    explicit Executor(std::string binary)
    {
        args_.push_back(binary);
    }

    Executor& container(const Container* container)
    {
        if (container != nullptr)
        {
            std::string path = path_ ? *path_ : "/";
            auto a = container->args();
            a.insert(a.end(), {"--chdir", path});
            args_.insert(args_.begin(), a.begin(), a.end());
            path_.reset();
            logger_ = container->logger;
        }
        return *this;
    }

    Executor& arg(const std::string& a)
    {
        args_.emplace_back(a);
        return *this;
    }

    Executor& path(const std::string& p)
    {
        path_ = p;
        return *this;
    }

    Executor& silent()
    {
        silent_ = true;
        return *this;
    }

    Executor& environ(const std::string& env)
    {
        environ_.push_back(env);
        return *this;
    }

    Executor& environ(const std::vector<std::string>& env)
    {
        environ_.insert(environ_.end(), env.begin(), env.end());
        return *this;
    }

    Executor& start()
    {
        auto binary = lookup_exec(args_[0]);
        if (!binary)
        {
            throw std::runtime_error(
                std::format("binary not found {}", args_[0]));
        }

        args_[0] = binary.value();
        if (pipe(pipe_fd) == -1)
        {
            throw std::runtime_error("pipe creating failed");
        }

        pid = fork();
        if (pid == -1)
        {
            throw std::runtime_error("failed to fork new process");
        }
        else if (pid == 0)
        {
            close(pipe_fd[READ]);

            dup2(pipe_fd[WRITE], STDOUT_FILENO);
            dup2(pipe_fd[WRITE], STDERR_FILENO);

            close(pipe_fd[WRITE]);

            if (path_)
                if (chdir(path_->c_str()) == -1)
                    throw std::runtime_error(
                        "failed to switch path to " + *path_);
            clearenv();

            std::vector<const char*> args;
            for (const auto& c : args_)
                args.emplace_back(c.c_str());
            args.push_back(nullptr);

            std::vector<const char*> env;
            for (const auto& c : environ_)
                env.emplace_back(c.c_str());
            env.push_back(nullptr);

            if (execve(args_[0].c_str(), (char* const*)args.data(),
                       (char* const*)env.data()) == -1)
            {
                perror("execution failed");
            }
            exit(EXIT_FAILURE);
        }
        return *this;
    }

    int wait(std::ostream* out = nullptr)
    {
        close(pipe_fd[WRITE]);

        char buffer[BUFSIZ] = {0};
        ssize_t bytes_read;
        while ((bytes_read = read(pipe_fd[READ], buffer, sizeof(buffer))) > 0)
        {
            if (out)
                out->write(buffer, bytes_read);
            if (logger_)
                logger_->write(buffer, bytes_read);
        }

        close(pipe_fd[READ]);
        int status;
        waitpid(pid, &status, 0);

        return WEXITSTATUS(status);
    }

    int run()
    {
        start();
        return wait(silent_ ? nullptr : &std::cout);
    }

    void execute()
    {
        if (!silent_)
        {
            dump_command(logger_ ? *logger_ : std::cout);
        }

        if (const auto status = run(); status != 0)
        {
            dump_command(std::cerr);
            if (logger_)
                dump_command(*logger_);
            throw std::runtime_error("failed to execute command : exit code " +
                                     std::to_string(status));
        }
    }

    void dump_command(std::ostream& os)
    {
        std::stringstream ss;
        for (const auto& a : args_)
        {
            ss << a << " ";
        }

        os << "COMMAND  : " << ss.str() << std::endl;
        os << "path     : " << (path_ ? *path_ : ".") << std::endl;
    }

    std::tuple<int, std::string> output()
    {
        std::stringstream output;
        start();
        int status = wait(&output);
        std::string output_data = output.str();
        output_data.shrink_to_fit();
        if (output_data.ends_with("\n"))
            output_data.pop_back();
        return {status, output_data};
    }
};
