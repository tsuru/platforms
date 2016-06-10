#!/bin/bash

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )

cd "$parent_path"

for plat in $(ls -d */ | cut -f1 -d'/'); do
    echo "Testing $plat platform..."
    sed "s/{PLATFORM}/$plat/g" Dockerfile.template > ./$plat/Dockerfile
    docker build -t platform-$plat ../$plat && docker build -t tests-$plat --no-cache ./$plat
    rm ./$plat/Dockerfile
done

