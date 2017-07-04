#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
}

@test "check if carton is intalled" {
    pushd ${CURRENT_DIR}
    run carton -v
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"carton v1"* ]]
}

@test "install from cpanfile" {
    echo "requires 'IO::Socket::IP';" > ${CURRENT_DIR}/cpanfile

    run /var/lib/tsuru/deploy

    pushd ${CURRENT_DIR}
    run carton install
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"IO-Socket-IP"* ]]
    rm ${CURRENT_DIR}/cpanfile
}