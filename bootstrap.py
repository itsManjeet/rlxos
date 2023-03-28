#!/usr/bin/env python3
import os
import pathlib
import subprocess
import sys
import time
from os import path

import yaml

BASE_DIR = pathlib.Path(__file__).parent.resolve().__str__()
IMAGE = "itsmanjeet/devel-docker:2200-3"

print("BASE DIR", BASE_DIR)


def run_in_container(args: list) -> int:
    print("executing", args)
    process = subprocess.Popen(["podman", "run",
                                "-v", path.join(BASE_DIR, "pkgupd.yml") + ":/etc/pkgupd.yml",
                                "-v", BASE_DIR + ":/rlxos",
                                "-v", path.join(BASE_DIR, "build", "storage") + ":/storage",
                                "--rm",
                                "-w", "/rlxos",
                                "-it", IMAGE] + [
                                   '/bin/env', '-i',
                                   'HOME=/rlxos',
                                   'TERM=linux',
                                   'PKGUPD_NO_PROGRESS=1',
                                   'PATH=' + path.join("/", "rlxos", "build", "root", "usr", "bin") + ':/usr/bin:/bin',
                               ] + args)

    while True:
        status = process.poll()
        if status is not None:
            return status

        time.sleep(1)


class Recipe:
    def __init__(self, filepath: str):
        self.path = filepath
        with open(self.path, 'r') as f:
            self.data = yaml.safe_load(f)

        self.verify()

    def verify(self):
        for key in ['id', 'version', 'about']:
            if key not in self.data:
                raise AttributeError(key + " in " + self.path)

    def depends(self):
        res = []
        if 'depends' in self.data:
            if 'runtime' in self.data['depends']:
                res += self.data['depends']['runtime']
            if 'buildtime' in self.data['depends']:
                res += self.data['depends']['buildtime']

        if 'include' in self.data:
            res += self.data['include']

        def cleanup(seq: list) -> list:
            seen = set()
            seen_add = seen.add
            return [x for x in seq if not (x in seen or seen_add(x))]

        if self.data['id'] in res:
            res.remove(self.data['id'])
        return cleanup(res)


def get_recipe_file(package_id: str) -> str:
    for p in pathlib.Path(path.join(BASE_DIR, "recipes")).rglob("**/%s/%s.yml" % (package_id, package_id)):
        return p.__str__()

    original_package_id = package_id
    if original_package_id == 'libldap':
        package_id = 'openldap'
    elif package_id.startswith('lib'):
        package_id = package_id.removeprefix('lib')

    for p in pathlib.Path(path.join(BASE_DIR, "recipes")).rglob("**/%s/%s.yml" % (package_id, package_id)):
        return p.__str__()

    raise FileNotFoundError(original_package_id)


visited_nodes = set()


def resolve_dependencies(package_id: str, tree: list, info_tree: list) -> list:
    recipe = Recipe(get_recipe_file(package_id))
    depends = recipe.depends()
    for depend in depends:
        if depend in visited_nodes:
            continue
        visited_nodes.add(depend)
        if depend not in tree:
            resolve_dependencies(depend, tree, info_tree)
    if package_id not in tree:
        tree.append(package_id)
        info_tree.append(recipe)
    return tree, info_tree


if len(sys.argv) == 1:
    print("Bootstrap:")
elif sys.argv[1] == "shell":
    run_in_container(["/bin/bash"])
elif sys.argv[1] == "update-pkgupd":
    build_dir = path.join("build", "pkgupd")
    if run_in_container(
            ["/bin/cmake", "-B", build_dir, "-S",
             path.join("src", "pkgupd"), "-DCMAKE_INSTALL_PREFIX=/usr"]) != 0:
        print("ERROR: failed to update pkgupd")
        sys.exit(1)

    if run_in_container(
            ["/bin/cmake", "--build", build_dir]) != 0:
        print("ERROR: failed to compile pkgupd")
        sys.exit(1)

    if run_in_container(["DESTDIR=" + path.join("build", "root"), "/bin/cmake", "--install", build_dir]) != 0:
        print("ERROR: failed to install pkgupd")
        sys.exit(1)
elif sys.argv[1] == "bootstrap":
    tree, info_tree = resolve_dependencies('rlxos-desktop', [], [])
    for i in info_tree:
        repository = i.path.removeprefix(BASE_DIR + "/recipes/").split('/')[0]
        recipe_path = i.path.replace(BASE_DIR, "/rlxos/")
        status = run_in_container(
            ['pkgupd', 'build', recipe_path, 'build.depends=false', 'build.env=false',
             'build.repository=' + repository])
        if status != 0:
            print("ERROR: failed to build ", i.data['id'], status)
            sys.exit(1)
