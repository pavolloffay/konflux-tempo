import os
from collections import OrderedDict
from sys import exit as sys_exit
from datetime import datetime
from ruamel.yaml import YAML
yaml = YAML()

annotations_file = "/metadata/annotations.yaml"

with open('./patch_annotations.yaml') as pf:
    patch = yaml.load(pf)

    with open(annotations_file, 'r') as f:
        upstream_annotations = yaml.load(f)
        upstream_annotations['annotations'].update(patch['extra_annotations'])

    with open(annotations_file, 'w') as f:
        yaml.dump(upstream_annotations, f)
