#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

latest=$(curl -sS -f https://golang.org/dl/?mode=json | jq -r '.[0].version')

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    rm -f /home/application/.default_procfile
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PATH=/home/application/go/bin:${PATH}
    rm -rf /home/application/go
}

@test "use latest Go version as default" {
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Go ${latest} (latest version)"* ]]
    [[ "$output" == *"Using Go version: go version ${latest} linux/amd64"* ]]

    run go version
    [ "$status" -eq 0 ]
    [[ "$output" == *"go version ${latest} linux/amd64"* ]]
}

@test "use Go version from GO_VERSION" {
    export GO_VERSION=1.10
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Go go1.10 (exact match from \$GO_VERSION)"* ]]
    [[ "$output" == *"Using Go version: go version go1.10 linux/amd64"* ]]

    run go version
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.10"* ]]
    unset GO_VERSION
}

@test "use Go version from GO_VERSION with .x as patch" {
    export GO_VERSION=1.10.x
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Go go1.10.8 (closest match from \$GO_VERSION=1.10.x)"* ]]
    [[ "$output" == *"Using Go version: go version go1.10.8 linux/amd64"* ]]

    run go version
    [ "$status" -eq 0 ]
    [[ "$output" == *"go1.10.8"* ]]
    unset GO_VERSION
}

@test "use latest Go version from GO_VERSION with .x as minor" {
    export GO_VERSION=1.x
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Go ${latest} (closest match from \$GO_VERSION=1.x)"* ]]
    [[ "$output" == *"Using Go version: go version ${latest} linux/amd64"* ]]

    run go version
    [ "$status" -eq 0 ]
    [[ "$output" == *"${latest}"* ]]
    unset GO_VERSION
}

@test "reuse installed Go version" {
    export GO_VERSION=1.x
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Go ${latest} (closest match from \$GO_VERSION=1.x)"* ]]
    [[ "$output" == *"Using Go version: go version ${latest} linux/amd64"* ]]

    run go version
    [ "$status" -eq 0 ]
    [[ "$output" == *"${latest}"* ]]

    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using already installed Go ${latest} (closest match from \$GO_VERSION=1.x)"* ]]
    [[ "$output" == *"Using Go version: go version ${latest} linux/amd64"* ]]

    unset GO_VERSION
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

@test "test using vendor and go mod for go >= 1.13" {
    cp -a ./fixtures/vendored/* ${CURRENT_DIR}/
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -x /home/application/bin/blah ]
    run /home/application/bin/blah
    [ "$status" -eq 0 ]
    [[ "$output" == *"compiled using vendor"* ]]
}
