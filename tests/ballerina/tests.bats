#!/usr/bin/env bats

# Copyright 2025 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir -p /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PATH=/usr/local/bin:${PATH}
}

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "ensure Ballerina is installed" {
    run bal version
    assert_success
    [[ "$output" == *"Ballerina 2201.13.1"* ]]
}

@test "bal command is available in PATH" {
    run which bal
    assert_success
    [[ "$output" == "/usr/local/bin/bal" ]]
}

@test "deploy simple Ballerina service" {
    cat <<EOF >${CURRENT_DIR}/hello_service.bal
import ballerina/http;

service /hello on new http:Listener(8888) {
    resource function get sayHello() returns string {
        return "Hello Ballerina!";
    }
}
EOF

    run /var/lib/tsuru/deploy
    assert_success
}
