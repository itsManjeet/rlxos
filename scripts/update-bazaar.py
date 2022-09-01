#!/usr/bin/env python3

from traceback import print_tb
import yaml
import os
import sys
from woocommerce import API

wcapi = API(
    url='https://rlxos.dev',
    consumer_key=os.getenv('BAZAAR_ID'),
    consumer_secret=os.getenv('BAZAAR_KEY'),
)

meta_file = sys.argv[1]
with open(meta_file, 'r') as f:
    package = yaml.safe_load(f)

response = wcapi.get('products?slug=%s' % package['id'])
category_id = 35
if package['repository'] == 'apps':
    category_id = 46
if len(response.json()) == 0:
    wcapi.post('products', data = {
        'name': package['id'],
        'type': 'simple',
        'description': package['about'],
        'virtual': True,
        'downloadable': True,
        'downloads': [{
            'name': 'Package File',
            'file': 'https://storage.rlxos.dev/stable/2200/pkgs/%s/%s-%s.%s' % (package['repository'], package['id'], package['version'], package['type'])
        }],
        'images': [{
            'src': 'https://storage.rlxos.dev/icons/%s.svg' % package['id'],
        }],
        'categories': [{
            'id': category_id,
        }]
    })
else:
    wcapi.post('products/%d' % response.json()[0]['id'], data = {
        'description': package['about'],
        'downloads': [{
            'name': 'Package File',
            'file': 'https://storage.rlxos.dev/stable/2200/pkgs/%s/%s-%s.%s' % (package['repository'], package['id'], package['version'], package['type'])
        }]
    })