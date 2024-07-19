import os
import yaml

def apply(fn):
    components = [os.path.join(dp, f) for dp, dn, filenames in os.walk("elements/components") for f in filenames if os.path.splitext(f)[1] == '.yml']
    count = 1
    total = len(components)
    for component in components:
        with open(component, "r") as file:
            data = yaml.safe_load(file)
            print(f"[{count}/{total}] checking {component}")
            fn(component, data)
            count += 1
