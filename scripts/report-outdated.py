#!/usr/bin/env python3

from common import apply

outdated = []

# TODO: implement is_outdated function
def is_outdated(name: str, version: str) -> str:
    return version

def callback(filename: str, data: dict):
    if 'id' in data and 'version' in data:
        name = data['id']
        version = data['version']

        new_version = is_outdated(name, version)
        if new_version != version:
            outdated.append([name, version, new_version])


print("checking outdated packages")
apply(callback)