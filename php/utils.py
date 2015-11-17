# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

import codecs

from tempfile import mkstemp
from shutil import move
import os


def replace(source_file_path, pattern, substring):
    fh, target_file_path = mkstemp()

    with codecs.open(target_file_path, 'w', 'utf-8') as target_file:
        with codecs.open(source_file_path, 'r', 'utf-8') as source_file:
            for line in source_file:
                target_file.write(line.replace(pattern, substring))
    os.remove(source_file_path)
    move(target_file_path, source_file_path)


def parse_env(configuration):
    return dict(
        os.environ.items() +
        parse_apprc().items() +
        parse_envs_from_configuration(configuration).items()
    )


def parse_apprc():
    path = "/tmp/app_envs"
    environments = {}
    if os.path.exists(path):
        with open(path) as file:
            for line in file.readlines():
                if "export" in line:
                    line = line.replace("export ", "")
                    k, v = line.split("=")
                    v = v.replace("\n", "").replace('"', '')

                    environments[k] = v

    return environments


def parse_envs_from_configuration(configuration):
    return configuration.get('envs', {})
