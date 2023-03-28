"""
Generates a Cargo.lock file for projects that refuse to
ship one. If a project does not have a Cargo.lock file,
stage this source before staging the `cargo` source.
"""

# We store the entirety of Cargo.lock in the ref, simply because
# running `cargo update` does not always result in the same Cargo.lock
# file. We don't want a fetch to effectively re-track the package

import os
from buildstream import Source, SourceError, Consistency
from buildstream import utils
import base64

class GenCargoLockSource(Source):
    BST_REQUIRED_VERSION_MAJOR = 1
    BST_REQUIRED_VERSION_MINOR = 3
    BST_REQUIRES_PREVIOUS_SOURCES_TRACK = True

    def configure(self, node):
        self.ref = self.node_get_member(node, str, "ref", None)
        self.node_validate(node, Source.COMMON_CONFIG_KEYS + ['ref'])

    def preflight(self):
        self.host_cargo = utils.get_host_tool("cargo")

    def get_unique_key(self):
        return self.ref

    def load_ref(self, node):
        self.ref = self.node_get_member(node, str, "ref", None)

    def get_ref(self):
        return self.ref

    def set_ref(self, ref, node):
        node['ref'] = self.ref = ref

    def get_consistency(self):
        if self.ref is None:
            return Consistency.INCONSISTENT
        return Consistency.CACHED

    def track(self, previous_sources_dir):
        # Generate a new Cargo.lock
        with self.timed_activity("Generating Cargo.lock"):
            command = [self.host_cargo, "update"]
            self.call(command, cwd=previous_sources_dir, fail="Error calling `cargo update`")

        # Encode Cargo.lock into base64
        output = os.path.join(previous_sources_dir, "Cargo.lock")
        try:
            with open(output, "r") as f:
                contents = f.read().encode("utf-8")
                new_ref = base64.b64encode(contents).decode("ascii")
        except:
            raise SourceError("Failed to encode Cargo.lock into base64")

        # Store it in the ref
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

# Entry point
def setup():
    return GenCargoLockSource
