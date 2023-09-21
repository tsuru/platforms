#!/bin/bash

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

DOCKER=${DOCKER:-docker}
NO_REBUILD=$2

parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )

cd "$parent_path"

if [ ! -z $1 ]; then
    platforms=$1
else
    platforms=$(ls -d */ | cut -f1 -d'/' | grep -v common)
fi

function run_test {
    local plat=$1
    echo "Testing $plat platform..."
    sed "s/{PLATFORM}/$plat/g" Dockerfile.template > ./$plat/Dockerfile
    cp -r common ./$plat/common
    if [ -z ${NO_REBUILD} ]; then
        ${DOCKER} build  -t platform-$plat ../$plat && ${DOCKER} build --progress plain -t tests-$plat --no-cache ./$plat
    else
        ${DOCKER} build --progress plain -t tests-$plat --no-cache ./$plat
    fi
    rm ./$plat/Dockerfile && rm -rf ./$plat/common
}

for plat in $platforms; do
    if [ ! -d "./${plat}" ]; then
        continue
    fi
    run_test $plat
done
