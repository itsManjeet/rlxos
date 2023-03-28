"""
Downloads all the dependencies of a go project
"""

import os
from buildstream import Source, SourceError, Consistency
from buildstream import utils

class GoVendorSource(Source):
    BST_REQUIRED_VERSION_MAJOR = 1
    BST_REQUIRED_VERSION_MINOR = 3
    BST_REQUIRES_PREVIOUS_SOURCES_TRACK = True
    BST_REQUIRES_PREVIOUS_SOURCES_FETCH = True

    def configure(self, node):
        self.ref = self.node_get_member(node, str, "ref", None)
        self.node_validate(node, Source.COMMON_CONFIG_KEYS + ["ref"])

    def preflight(self):
        self.host_go = utils.get_host_tool("go")

        # Check Go version
        _, stdout = self.check_output([self.host_go, "version"], fail="Error calling `go version`")
        version = tuple(int(x) for x in stdout.split(" ")[2][2:].split("."))
        if version < (1, 14):
            raise SourceError("Host go version is too old (need 1.14+)")

    def get_unique_key(self):
        return self.ref

    def load_ref(self, node):
        self.ref = self.node_get_member(node, str, "ref", None)

    def get_ref(self):
        return self.ref

    def set_ref(self, ref, node):
        node["ref"] = self.ref = ref

    def _get_cache_dir(self, ref=None):
        if ref is None:
            ref = self.ref
        return os.path.join(self.get_mirror_directory(), ref)

    def _ensure_cached(self, ref, previous_sources_dir):
        target = self._get_cache_dir(ref)
        os.makedirs(target, exist_ok=True)
        with self.timed_activity("Fetching go dependencies"):
            command = [self.host_go, "mod", "vendor"]
            self.call(command, cwd=previous_sources_dir, fail="Error calling `go mod vendor`")
            utils.copy_files(os.path.join(previous_sources_dir, "vendor"), target)

    def get_consistency(self):
        if self.ref is None:
            return Consistency.INCONSISTENT

        check = os.path.join(self._get_cache_dir(), "modules.txt")
        if os.path.exists(check):
            return Consistency.CACHED

        return Consistency.RESOLVED

    def track(self, previous_sources_dir):
        go_sum = os.path.join(previous_sources_dir, "go.sum")
        new_ref = utils.sha256sum(go_sum)
        self._ensure_cached(new_ref, previous_sources_dir)
        return new_ref

    def fetch(self, previous_sources_dir):
        self._ensure_cached(self.ref, previous_sources_dir)

    def stage(self, directory):
        source = self._get_cache_dir()
        target = os.path.join(directory, "vendor")
        with self.timed_activity("Staging go dependencies"):
            utils.copy_files(source, target)

def setup(): # Entry point
    return GoVendorSource
