#!/usr/bin/env python3

import sys, os
import yaml
import shutil
from jinja2 import Environment

with open('.version') as f:
    VERSION = f.read()

RECIPE_DIR = 'build/{}/recipes'.format(VERSION)
if os.path.exists(RECIPE_DIR):
    shutil.rmtree(RECIPE_DIR)

os.makedirs(RECIPE_DIR)

FAILED = []

for file in os.listdir('recipes/'):
    if file.endswith('.yml'):
        with open('recipes/{}'.format(file)) as f:
            data = f.read()
            obj = yaml.full_load(data)
            try:
                if 'packages' in obj and len(obj['packages']) != 1:
                    FAILED.append(file)
                data = Environment().from_string(data).render(obj)
                with open('{}/{}'.format(RECIPE_DIR,file),'w') as fw:
                    fw.write(data)
            except Exception as e:
                FAILED.append(file)

print("failed", FAILED)
