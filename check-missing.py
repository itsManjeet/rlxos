#!/bin/python

from yaml import safe_load, YAMLError
from os import listdir, path


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

for recipeFile in listdir('recipes'):
    recipe = readRecipe(path.join('recipes', recipeFile))
    if recipe is None:
        continue

    pkgs = listPackages(recipe)
    for pkg in pkgs:
        if not path.exists('pkgs/%s' % pkg):
            MISSING_PKGS.add(recipe['id'])
            print('MISSING %s from %s' % (pkg, recipe['id']))

with open('missing.profile','w') as stream:
    stream.writelines(['id = missing\n', 'packages = %s\n' % ' '.join(MISSING_PKGS), 'release = 2110\n'])