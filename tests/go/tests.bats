#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    rm -f /home/application/.default_procfile
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
}

@test "use Go version 1.13.1 as default" {
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using Go version: go version go1.13.1 linux/amd64"* ]]

    pushd ${CURRENT_DIR}
    run go version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"go version go1.13.1 linux/amd64"* ]]
}

@test "use existing Go version from GO_VERSION" {
    export GO_VERSION=1.11
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" != *"Installing Go"* ]]
    [[ "$output" == *"Using Go version: go version go1.11.13 linux/amd64"* ]]

    pushd ${CURRENT_DIR}
    run go version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"1.11.13"* ]]
    unset GO_VERSION
}

@test "use downloaded Go version from GO_VERSION" {
    export GO_VERSION=1.10
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Go"* ]]
    [[ "$output" == *"Using Go version: go version go1.10 linux/amd64"* ]]

    pushd ${CURRENT_DIR}
    run go version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"1.10"* ]]
    unset GO_VERSION
}

@test "use existing version when download is not allowed" {
    export GO_VERSION=1.9
    export GO_DOWNLOAD_ALLOWED=false
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" != *"Installing Go"* ]]
    [[ "$output" == *"Requested Go version is 1.9 but download is not allowed."* ]]
    [[ "$output" == *"Using Go version: go version go1.13.1 linux/amd64"* ]]

    pushd ${CURRENT_DIR}
    run go version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"1.13.1"* ]]
    unset GO_VERSION
    unset GO_DOWNLOAD_ALLOWED
}

@test "test project rootmain default procfile" {
    cp -a ./fixtures/rootmain/* ${CURRENT_DIR}/
    touch /home/application/.default_procfile
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -x ${CURRENT_DIR}/tsuru-app ]
    run ${CURRENT_DIR}/tsuru-app
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
}

@test "test project rootmain custom procfile" {
    cp -a ./fixtures/rootmain/* ${CURRENT_DIR}/
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -x ${CURRENT_DIR}/current ]
    run ${CURRENT_DIR}/current
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]

    [ -x /home/application/bin/current ]
    run /home/application/bin/current
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
}

@test "test project selfreferencing default procfile" {
    cp -a ./fixtures/selfreferencing/* ${CURRENT_DIR}/
    touch /home/application/.default_procfile
    run /var/lib/tsuru/deploy
    [ "$status" -eq 1 ]
    [[ "$output" == *"cannot find package \"github.com/tsuru/foo/api\""* ]]
}

@test "test project selfreferencing default procfile with GO_PKG_PATH" {
    export GO_PKG_PATH="github.com/tsuru/foo"
    cp -a ./fixtures/selfreferencing/* ${CURRENT_DIR}/
    touch /home/application/.default_procfile
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -x ${CURRENT_DIR}/tsuru-app ]
    run ${CURRENT_DIR}/tsuru-app
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]

    unset GO_PKG_PATH
}

@test "test project selfreferencing custom procfile with GO_PKG_PATH" {
    export GO_PKG_PATH="github.com/tsuru/foo"
    cp -a ./fixtures/selfreferencing/* ${CURRENT_DIR}/
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -x ${CURRENT_DIR}/foo ]
    run ${CURRENT_DIR}/foo
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]

    [ -x /home/application/bin/foo ]
    run /home/application/bin/foo
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]

    unset GO_PKG_PATH
}

@test "test project nonrootmain default procfile" {
    cp -a ./fixtures/nonrootmain/* ${CURRENT_DIR}/
    touch /home/application/.default_procfile
    run /var/lib/tsuru/deploy
    [ "$status" -eq 1 ]
    [[ "$output" == *"no Go files"* ]]
}

@test "test project nonrootmain custom procfile" {
    cp -a ./fixtures/nonrootmain/* ${CURRENT_DIR}/
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -x /home/application/bin/cmd ]
    run /home/application/bin/cmd
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
}

@test "test project selfreferencingnonroot custom procfile with GO_PKG_PATH" {
    export GO_PKG_PATH="github.com/tsuru/foo"
    cp -a ./fixtures/selfreferencingnonroot/* ${CURRENT_DIR}/
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -x /home/application/bin/cmd ]
    run /home/application/bin/cmd
    [ "$status" -eq 0 ]
    [[ "$output" == *"ok"* ]]
    unset GO_PKG_PATH
}
