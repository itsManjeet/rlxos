"""
Generates a Cargo.lock file for projects that refuse to
ship one. If a project does not have a Cargo.lock file,
stage this source before staging the `cargo` source.
"""

import os
from buildstream import Source, SourceError, utils
import base64

class GenCargoLockSource(Source):
    BST_MIN_VERSION = "2.0"
    BST_REQUIRES_PREVIOUS_SOURCES_TRACK = True

    def configure(self, node):
        node.validate_keys(Source.COMMON_CONFIG_KEYS + ["ref"])
        self.ref = node.get_str("ref", None)

    def preflight(self):
        # We would normally call utils.get_host_tool here, but this would introduce
        # a dependency on cargo on the host, even though we don't really need it for
        # anything other than tracking. So, we actually only look for the host cargo
        # in the track method
        self.host_cargo = None

    def get_unique_key(self):
        return self.ref

    def load_ref(self, node):
        self.ref = node.get_str("ref", None)

    def get_ref(self):
        return self.ref

    def set_ref(self, ref, node):
        node['ref'] = self.ref = ref

    def track(self, previous_sources_dir):
        if self.host_cargo is None:
            self.host_cargo = utils.get_host_tool("cargo")
    
        # Generate a new Cargo.lock
        with self.timed_activity("Generating Cargo.lock"):
            command = [self.host_cargo, "generate-lockfile"]
            env = { "CARGO_HOME": self.get_mirror_directory(), **os.environ }
            self.call(command, cwd=previous_sources_dir, env=env, fail="Failed to generate lockfile")

        # Encode Cargo.lock into base64
        output = os.path.join(previous_sources_dir, "Cargo.lock")
        try:
            with open(output, "r") as f:
                contents = f.read().encode("utf-8")
                new_ref = base64.b64encode(contents).decode("ascii")
        except:
            raise SourceError("Failed to encode Cargo.lock into base64")

        # We store the entirety of Cargo.lock in the ref, simply because
        # running `cargo generate-lockfile` does not always result in the
        # same Cargo.lock file. We don't want a fetch to effectively re-track
        # the package
        return new_ref

    def fetch(self):
        pass

    def stage(self, directory):
        # Decode the base64 to get back Cargo.lock
        cargo_lock = base64.b64decode(self.ref.encode("ascii")).decode("utf-8")

        # Write the file into the sandbox
        target = os.path.join(directory, "Cargo.lock")
        try:
            with open(target, "w") as f:
                f.write(cargo_lock)
        except:
            raise SourceError("Failed to stage Cargo.lock")

    def is_cached(self):
        return True

# Entry point
def setup():
    return GenCargoLockSource
