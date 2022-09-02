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

if package['repository'] == 'core' or \
    package['repository'] == 'extra':
    sys.exit(0)

icon_file = ''
for ext in ['png', 'svg', 'jpg', 'jpeg']:
    if os.path.exists(meta_file.replace('.yml', '.' + ext)):
        icon_file = meta_file.replace('.yml', '.' + ext)
        print('using icon %s' % icon_file)
        break

response = wcapi.get('products?slug=%s' % package['id'])
category_id = 35
if package['repository'] == 'apps':
    category_id = 46
if len(response.json()) == 0:
    meta_data = {
        'name': package['id'],
        'type': 'simple',
        'description': package['about'],
        'virtual': True,
        'downloadable': True,
        'downloads': [{
            'name': 'Package File',
            'file': 'https://storage.rlxos.dev/stable/2200/pkgs/%s/%s-%s.%s' % (package['repository'], package['id'], package['version'], package['type'])
        }],
        'categories': [{
            'id': category_id,
        }]
    }
    if len(icon_file) != 0:
        meta_data['images'] = [{
            'src': 'https://storage.rlxos.dev/' + icon_file,
        }],
    response = wcapi.post('products', data = meta_data)
else:
    response = wcapi.post('products/%d' % response.json()[0]['id'], data = {
        'description': package['about'],
        'downloads': [{
            'name': 'Package File',
            'file': 'https://storage.rlxos.dev/stable/2200/pkgs/%s/%s-%s.%s' % (package['repository'], package['id'], package['version'], package['type'])
        }]
    })

if response.status_code == 200 or \
    response.status_code == 201:
    print('success')
else:
    print(response.status_code, response.json()['message'])