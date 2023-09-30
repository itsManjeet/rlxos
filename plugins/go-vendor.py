"""
Downloads all the dependencies of a go project
"""

import os
from buildstream import Source, SourceError
from buildstream import utils

class GoVendorSource(Source):

    BST_MIN_VERSION = "2.0"
    BST_REQUIRES_PREVIOUS_SOURCES_TRACK = True
    BST_REQUIRES_PREVIOUS_SOURCES_FETCH = True

    def configure(self, node):
        node.validate_keys(Source.COMMON_CONFIG_KEYS + ["ref"])
        self.ref = node.get_str("ref", None)

    def preflight(self):
        self.host_go = utils.get_host_tool("go")

        # Check Go version
        _, stdout = self.check_output([self.host_go, "version"])
        version = tuple(int(x) for x in stdout.split(" ")[2][2:].split("."))
        if version < (1, 14):
            raise SourceError("Host go version is too old (need 1.14+)")

    def get_unique_key(self):
        return self.ref

    def load_ref(self, node):
        self.ref = node.get_str("ref")

    def get_ref(self):
        return self.ref

    def set_ref(self, ref, node):
        node["ref"] = self.ref = ref

    def _get_cache_dir(self, name=None):
        return os.path.join(self.get_mirror_directory(), name or self.ref)

    def track(self, previous_sources_dir):
        go_sum = os.path.join(previous_sources_dir, "go.sum")
        return utils.sha256sum(go_sum)

    def fetch(self, previous_sources_dir):
        target = self._get_cache_dir()
        os.makedirs(target, exist_ok=True)
        with self.timed_activity("Fetching go dependencies"):
            command = [self.host_go, "mod", "vendor", "-o", target]
            env = { "GOPATH": self._get_cache_dir("go"), **os.environ }
            self.call(command, cwd=previous_sources_dir, env=env, fail="Failed to vendor go dependencies")

    def stage(self, directory):
        source = self._get_cache_dir()
        target = os.path.join(directory, "vendor")
        with self.timed_activity("Staging go dependencies"):
            utils.copy_files(source, target)

    def is_cached(self):
        chkpath = os.path.join(self._get_cache_dir(), "modules.txt")
        return os.path.exists(chkpath)

def setup(): # Entry point
    return GoVendorSource
