#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
}

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "check if carton is installed" {
    pushd ${CURRENT_DIR}
    run carton -v
    popd

    assert_success
    [[ "$output" == *"carton v1"* ]]
}

@test "install from cpanfile" {
    echo "requires 'IO::Socket::IP';" > ${CURRENT_DIR}/cpanfile

    run /var/lib/tsuru/deploy

    pushd ${CURRENT_DIR}
    run carton install
    popd

    assert_success
    rm ${CURRENT_DIR}/cpanfile
}
