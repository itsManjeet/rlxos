#!/bin/python

import sys, os
import yaml
from jinja2 import Environment

with open('.version') as f:
    VERSION = f.read()


for file in os.listdir('recipes/'):
    if file.endswith('.yml'):
        with open('recipes/{}'.format(file)) as f:
            data = f.read()
            obj = yaml.full_load(data)
            try:
                data = Environment().from_string(data).render(obj)
                with open('build/{}/recipes/{}'.format(VERSION,file),'w') as fw:
                    fw.write(data)
            except Exception as e:
                print(str(e), file)
