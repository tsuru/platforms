#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
}

load '../bats-support-master/load'
load '../bats-assert-master/load'

@test "has runnable deploy script" {
    [ -x "/var/lib/tsuru/deploy" ]
}

@test "deploy script uses the base scripts" {
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"ran base deploy"* ]]
}
