#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

latest=$(curl -sS -f https://go.dev/dl/?mode=json | jq -r '.[0].version')

setup() {
  rm -rf /home/application/current && mkdir /home/application/current
  rm -f /home/application/.default_procfile
  chown ubuntu /home/application/current
  export CURRENT_DIR=/home/application/current
  export PATH=/home/application/go/bin:${PATH}
  rm -rf /home/application/go
}

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "use latest Go version as default" {
  run /var/lib/tsuru/deploy
  assert_success
  [[ "$output" == *"Installing Go ${latest} (latest version)"* ]]
  [[ "$output" == *"Using Go version: go version ${latest} linux/amd64"* ]]

  run go version
  assert_success
  [[ "$output" == *"go version ${latest} linux/amd64"* ]]
}

@test "use Go version from GO_VERSION" {
  export GO_VERSION=1.10
  run /var/lib/tsuru/deploy
  assert_success
  [[ "$output" == *"Installing Go go1.10 (exact match from \$GO_VERSION)"* ]]
  [[ "$output" == *"Using Go version: go version go1.10 linux/amd64"* ]]

  run go version
  assert_success
  [[ "$output" == *"go1.10"* ]]
  unset GO_VERSION
}

@test "use Go version from GO_VERSION with .x as patch" {
  export GO_VERSION=1.10.x
  run /var/lib/tsuru/deploy
  assert_success
  [[ "$output" == *"Installing Go go1.10.8 (closest match from \$GO_VERSION=1.10.x)"* ]]
  [[ "$output" == *"Using Go version: go version go1.10.8 linux/amd64"* ]]

  run go version
  assert_success
  [[ "$output" == *"go1.10.8"* ]]
  unset GO_VERSION
}

@test "use latest Go version from GO_VERSION with .x as minor" {
  export GO_VERSION=1.x
  run /var/lib/tsuru/deploy
  assert_success
  [[ "$output" == *"Installing Go ${latest} (closest match from \$GO_VERSION=1.x)"* ]]
  [[ "$output" == *"Using Go version: go version ${latest} linux/amd64"* ]]

  run go version
  assert_success
  [[ "$output" == *"${latest}"* ]]
  unset GO_VERSION
}

@test "test project rootmain default procfile" {
  cp -a ./fixtures/rootmain/* ${CURRENT_DIR}/
  touch /home/application/.default_procfile
  run /var/lib/tsuru/deploy
  assert_success

  [ -x ${CURRENT_DIR}/tsuru-app ]
  run ${CURRENT_DIR}/tsuru-app
  assert_success
  [[ "$output" == *"ok"* ]]
}

@test "test project rootmain custom procfile" {
  cp -a ./fixtures/rootmain/* ${CURRENT_DIR}/
  run /var/lib/tsuru/deploy
  assert_success

  [ -x ${CURRENT_DIR}/rootmain ]
  run ${CURRENT_DIR}/rootmain
  assert_success
  [[ "$output" == *"ok"* ]]

  [ -x /home/application/bin/rootmain ]
  run /home/application/bin/rootmain
  assert_success
  [[ "$output" == *"ok"* ]]
}

@test "test project selfreferencing default procfile" {
  cp -a ./fixtures/selfreferencing/* ${CURRENT_DIR}/
  # Making sure that Go module is not going to match the internal package name "github.com/tsuru/foo"
  echo "module foo" >${CURRENT_DIR}/go.mod

  touch /home/application/.default_procfile
  run /var/lib/tsuru/deploy
  [ "$status" -eq 1 ]
  [[ "$output" == *"no required module provides package github.com/tsuru/foo/api"* ]]
}

@test "test project selfreferencing default procfile with GO_PKG_PATH" {
  export GO_PKG_PATH="github.com/tsuru/foo"
  cp -a ./fixtures/selfreferencing/* ${CURRENT_DIR}/
  touch /home/application/.default_procfile
  run /var/lib/tsuru/deploy
  assert_success

  [ -x ${CURRENT_DIR}/tsuru-app ]
  run ${CURRENT_DIR}/tsuru-app
  assert_success
  [[ "$output" == *"ok"* ]]

  unset GO_PKG_PATH
}

@test "test project selfreferencing custom procfile with GO_PKG_PATH" {
  export GO_PKG_PATH="github.com/tsuru/foo"
  cp -a ./fixtures/selfreferencing/* ${CURRENT_DIR}/
  run /var/lib/tsuru/deploy
  assert_success

  [ -x ${CURRENT_DIR}/foo ]
  run ${CURRENT_DIR}/foo
  assert_success
  [[ "$output" == *"ok"* ]]

  [ -x /home/application/bin/foo ]
  run /home/application/bin/foo
  assert_success
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
  assert_success

  [ -x /home/application/bin/cmd ]
  run /home/application/bin/cmd
  assert_success
  [[ "$output" == *"ok"* ]]
}

@test "test project selfreferencingnonroot custom procfile with GO_PKG_PATH" {
  export GO_PKG_PATH="github.com/tsuru/foo"
  cp -a ./fixtures/selfreferencingnonroot/* ${CURRENT_DIR}/
  run /var/lib/tsuru/deploy
  assert_success

  [ -x /home/application/bin/cmd ]
  run /home/application/bin/cmd
  assert_success
  [[ "$output" == *"ok"* ]]
  unset GO_PKG_PATH
}

@test "test using vendor and go mod for go >= 1.13" {
  cp -a ./fixtures/vendored/* ${CURRENT_DIR}/
  run /var/lib/tsuru/deploy
  assert_success

  [ -x /home/application/bin/blah ]
  run /home/application/bin/blah
  assert_success
  [[ "$output" == *"compiled using vendor"* ]]
}

@test "test project with multiple processes" {
  cp -a ./fixtures/multipleprocesses/* ${CURRENT_DIR}/
  run /var/lib/tsuru/deploy
  assert_success

  [ -f /home/application/bin/api ]
  [ -s /home/application/bin/api ]

  [ -f /home/application/bin/worker ]
  [ -s /home/application/bin/worker ]
}

@test "test project with multiple processes and tsuru.yaml" {
  cp -a ./fixtures/multipleprocesses-tsuruyaml/* ${CURRENT_DIR}/
  run /var/lib/tsuru/deploy
  assert_success

  [ -f /home/application/bin/api ]
  [ -s /home/application/bin/api ]

  [ -f /home/application/bin/worker ]
  [ -s /home/application/bin/worker ]
}

