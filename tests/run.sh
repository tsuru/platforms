#!/bin/bash

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )

cd "$parent_path"

has_parallel=$(which parallel)

if [ ! -z $1 ]; then
    platforms=$1
    has_parallel=""
else
    platforms=$(ls -d */ | cut -f1 -d'/' | grep -v common)
fi

export failure_file=$(mktemp)

function run_test {
    local plat=$1
    echo "Testing $plat platform..."
    sed "s/{PLATFORM}/$plat/g" Dockerfile.template > ./$plat/Dockerfile
    cp -r common ./$plat/common
    docker build -t platform-$plat ../$plat && docker build -t tests-$plat --no-cache ./$plat
    if [ "$?" != "0" ]; then
        echo "errors in platform ${plat}" >> "$failure_file"
    fi
    rm ./$plat/Dockerfile && rm -rf ./$plat/common
}
export -f run_test

for plat in $platforms; do
    if [ ! -d "./${plat}" ]; then
        continue
    fi
    if [ "${has_parallel}" ]; then
        parallel --semaphore -j 10 run_test $plat
    else
        set -e
        run_test $plat
    fi
done

if [ "${has_parallel}" ]; then
    parallel --semaphore --wait
fi

if [ -s "$failure_file" ]; then
    echo "FAILURES FOUND:"
    cat $failure_file
    exit 1
fi
rm "$failure_file"
