import os
import re
from buildstream import Element, ElementError, Scope

class ExtractInitialScriptsElement(Element):
    BST_FORBID_RDEPENDS = True
    BST_FORBID_SOURCES = True

    BST_STRICT_REBUILD = True
    BST_ARTIFACT_VERSION = 1

    def configure(self, node):
        self.node_validate(node, [
            'path',
        ])

        self.path = self.node_subst_member(node, 'path')

    def preflight(self):
        pass

    def get_unique_key(self):
        key = {
            'path': self.path,
        }
        return key

    def configure_sandbox(self, sandbox):
        pass

    def stage(self, sandbox):
        pass

    def assemble(self, sandbox):
        basedir = sandbox.get_directory()
        path = os.path.join(basedir, self.path.lstrip(os.sep))
        index = 0
        for dependency in self.dependencies(Scope.BUILD):
            public = dependency.get_public_data('initial-script')
            if public and 'script' in public:
                script = self.node_subst_member(public, 'script')
                index += 1
                depname = re.sub('[^A-Za-z0-9]', '_', dependency.name)
                basename = '{:03}-{}'.format(index, depname)
                filename = os.path.join(path, basename)
                os.makedirs(path, exist_ok=True)
                with open(filename, 'w') as f:
                    f.write(script)
                os.chmod(filename, 0o755)

        return os.sep

def setup():
    return ExtractInitialScriptsElement
