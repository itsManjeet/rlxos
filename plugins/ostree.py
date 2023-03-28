from buildstream import Element, Scope, SandboxFlags, ElementError
import os


class OstreeElement(Element):
    BST_FORBID_RDEPENDS = True
    BST_FORBID_SOURCES = True
    BST_STRICT_REBUILD = True

    def preflight(self):
        pass

    def configure(self, node):
        self.node_validate(node, ["environment", "ostree-branch", "initial-commands"])

        self.env = self.node_subst_list(node, "environment")
        self.branch = self.node_subst_member(node, "ostree-branch")
        self.initial_commands = self.node_subst_list(node, "initial-commands")

    def get_unique_key(self):
        return {"branch": self.branch, "initial-commands": self.initial_commands}

    def configure_sandbox(self, sandbox):
        sandbox.mark_directory(self.get_variable("build-root"), artifact=True)
        sandbox.mark_directory(self.get_variable("install-root"))

        sandbox.set_environment(self.get_environment())

    def stage(self, sandbox):
        env = []
        source_deps = []
        for dep in self.dependencies(Scope.BUILD, recurse=False):
            if dep.name in self.env:
                self.status("{} in environment".format(dep.name))
                env.append(dep)
            else:
                self.status("{} in sysroot".format(dep.name))
                source_deps.append(dep)

        with self.timed_activity("Staging environment", silent_nested=True):
            for build_dep in env:
                build_dep.stage_dependency_artifacts(sandbox, Scope.RUN)

        with self.timed_activity("Integrating sandbox", silent_nested=True):
            for build_dep in env:
                for dep in build_dep.dependencies(Scope.RUN):
                    dep.integrate(sandbox)

        for build_dep in source_deps:
            build_dep.stage_dependency_artifacts(
                sandbox, Scope.RUN, path=self.get_variable("sysroot")
            )

    def assemble(self, sandbox):
        def run_command(*command):
            exitcode = sandbox.run(command, SandboxFlags.ROOT_READ_ONLY)
            if exitcode != 0:
                raise ElementError(
                    "Command '{}' failed with exitcode {}".format(
                        " ".join(command), exitcode
                    )
                )

        sysroot = self.get_variable("sysroot")
        barerepopath = os.path.join(self.get_variable("build-root"), "barerepo")
        repopath = self.get_variable("install-root")

        with self.timed_activity("Running initial commands"):
            for command in self.initial_commands:
                run_command("sh", "-c", command)

        with self.timed_activity("Initial commit"):
            # ostree doesn't like the fuse filesystem buildstream uses to prevent artifact corruption
            # so disable it. This should be safe as ostree shouldn't modify the files contents now
            sandbox.mark_directory(self.get_variable("build-root"), artifact=False)

            run_command("ostree", "init", "--repo", barerepopath)
            run_command(
                "ostree",
                "commit",
                "--repo",
                barerepopath,
                "--consume",
                sysroot,
                "--branch",
                self.branch,
                "--timestamp",
                "2011-11-11 11:11:11+00:00",
            )

        with self.timed_activity("Pull"):
            run_command("ostree", "init", "--repo", repopath, "--mode", "archive")
            run_command("ostree", "pull-local", "--repo", repopath, barerepopath)

        return repopath


def setup():
    return OstreeElement
