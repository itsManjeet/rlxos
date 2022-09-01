#!/usr/bin/env python3

import yaml
import os
import sys
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
print("status: %d" % all_products_resp.status_code)

if all_products_resp.status_code != 200 and \
        all_products_resp.status_code != 201:
    print("Failed to retrieve code %d, %s" %
          (all_products_resp.status_code, all_products_resp.json()['message']))
    sys.exit(1)

bazaar_cache = all_products_resp.json()

def getPackage(name: str) -> int:
    for product in bazaar_cache:
        if product['name'] == name:
            return product['id']
    return -1

for product in bazaar_cache:
    print('BAZAAR %s' % product['name'])

bulk_cache = {
    'create': [],
    'update': [],
    'delete': []
}


bazaar_idx = -1
for package in bazaar_cache:
    bazaar_idx += 1
    local_package_data = {}
    idx = -1
    for i in repositories:
        idx += 1
        if i['id'] == package['name']:
            local_package_data = i
            break

    if len(local_package_data) == 0:
        print('deleting %s' % package['name'])
        bulk_cache['delete'].append(package['id'])
    else:
        print('updating %s' % package['name'])
        bulk_cache['update'].append({
            'id': package['id'],
            'downloads': [{
                'name': 'Package File',
                'file': 'https://storage.rlxos.dev/stable/2200/pkgs/%s/%s-%s.%s' % (i['repository'], i['id'], i['version'], i['type'])
            }]
        })
    repositories.pop(idx)
    bazaar_cache.pop(bazaar_idx)

for product in bazaar_cache:
    bulk_cache['delete'].append(product['id'])

for package in repositories:
    print('adding %s' % package['id'])
    category_id = 35
    if package['repository'] == 'apps':
        category_id = 46
    bulk_cache['create'].append({
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

