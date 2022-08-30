#!/usr/bin/env python3

import yaml
import os
from woocommerce import API


repositories = []
for repo in ['apps', 'machine', 'system']:
    with open('/var/cache/pkgupd/repo/%s' % repo) as f:
        data = yaml.safe_load(f)
        if 'pkgs' in data and data['pkgs'] is not None:
            repositories += data['pkgs']

wcapi = API(
    url='https://rlxos.dev',
    consumer_key=os.getenv('BAZAAR_ID'),
    consumer_secret=os.getenv('BAZAAR_KEY'),
)

all_products_resp = wcapi.get('products')

def getPackage(name: str) -> int:
    for product in all_products_resp.json():
        if product['name'] == name:
            return product['id']
    return -1


for package in repositories:
    id = getPackage(package['id'])
    category_id = 35
    if package['repository'] == 'apps':
        category_id = 46
    data = {
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
    }
    if id == -1:
        print("adding package", package['id'])
        resp = wcapi.post('products', data=data)
    else:
        data['id'] = id
        print("updating product %d" % id)
        resp = wcapi.post('products/%d' % id, data=data)
    
    if resp.status_code != 200 and resp.status_code != 201:
        print('response', resp.status_code, resp.text)
