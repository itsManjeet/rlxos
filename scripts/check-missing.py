#!/bin/env python3

from yaml import safe_load, YAMLError
from os import listdir, path, system


def readRecipe(filepath: str) -> dict:
    with open(filepath, 'r') as f:
        try:
            return safe_load(f)
        except YAMLError as err:
            print('Failed to read', filepath, err)
            return None


def generatePackageName(recipe: dict, pkgid: str) -> str:
    if pkgid == 'pkg':
        pkgid = recipe['id']
    elif pkgid == 'lib' or pkgid == 'lib32':
        pkgid += recipe['id']
    else:
        pkgid = recipe['id'] + '-' + pkgid
    return '%s-%s.rlx' % (pkgid, recipe['version'])


def listPackages(recipe: dict) -> list:
    pkgs = []
    for i in recipe['packages']:
        pkgs.append(generatePackageName(recipe, i['id']))

    return pkgs

MISSING_PKGS = set()

with open('.version') as f:
    VERSION = f.read()

PKGDIR = path.join("build",VERSION, "pkgs")
RECIPEDIR = path.join("build",VERSION, "recipes")

for recipeFile in listdir(RECIPEDIR):
    recipe = readRecipe(path.join(RECIPEDIR, recipeFile))
    if recipe is None:
        continue

    pkgs = listPackages(recipe)
    for pkg in pkgs:
        if not path.exists('%s/%s' % (PKGDIR,pkg)):
            MISSING_PKGS.add(recipe['id'])
            print('MISSING %s from %s' % (pkg, recipe['id']))

for i in MISSING_PKGS:
    print(i)