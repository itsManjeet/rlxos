#!/bin/python

import sys, os
import yaml
from jinja2 import Environment

for file in os.listdir('recipes/'):
    if file.endswith('.yml'):
        with open('recipes/{}'.format(file)) as f:
            data = f.read()
            obj = yaml.full_load(data)
            data = Environment().from_string(data).render(obj)
            with open('build/recipes/{}'.format(file),'w') as fw:
                fw.write(data)
