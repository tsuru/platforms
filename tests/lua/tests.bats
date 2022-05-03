#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "installs lua" {
  run /usr/bin/lua -v
  assert_success
  [[ "$output" == *"Lua 5.4"* ]]
}

@test "install luarocks" {
  luarocks --help | grep LuaRocks | grep "a module deployment system for Lua"
}
