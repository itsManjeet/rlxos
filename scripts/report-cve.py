#!/usr/bin/env python3

from common import apply

vulnerable = []

# TODO: implement check_cve function
def check_cve(name: str, version: str) -> list:
    return None

def callback(filename: str, data: dict):
    if 'id' in data and 'version' in data:
        name = data['id']
        version = data['version']

        vulnerablities = check_cve(name, version)
        if vulnerablities != None:
            vulnerable.append([name, version, vulnerablities])


print("checking CVE packages")
apply(callback)