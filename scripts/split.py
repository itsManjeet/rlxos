#!/bin/env python3

from struct import pack
import sys
import yaml
import os

FILE = sys.argv[1]
with open(FILE, 'r') as file:
    data = yaml.safe_load(file)

for i in data['packages']:
    if i['id'] == 'pkg':
        continue

    package = {
        'id': i['id'],
        'version': '7',
        'about': 'xorg fonts ' + i['id'],
        'build-dir': i['dir'],
        'sources': i['sources']
    }

    with open(os.path.join('recipes', i['id']+'.yml'), 'w') as file:
        yaml.safe_dump(package, file, sort_keys=False)