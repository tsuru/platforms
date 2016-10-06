#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

@test "installs lua" {
  lua -v | grep "Lua 5.1"
}

@test "install luarocks" {
  luarocks --help | grep LuaRocks | grep "a module deployment system for Lua"
}
