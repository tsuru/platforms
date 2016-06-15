#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

@test "installs ruby" {
    dpkg -s ruby | grep "install ok installed"
}

@test "installs build-essential" {
    dpkg -s build-essential | grep "install ok installed"
}

@test "has runnable deploy script" {
    [ -x "/var/lib/tsuru/deploy" ]
}

@test "deploy script uses the base scripts" {
    run /var/lib/tsuru/deploy
    [[ "$output" == *"ran base deploy"* ]]
    [[ "$output" == *"ran base config"* ]]
}

@test "install ruby version 2.3.1 as default" {
    run /home/application/ruby/bin/ruby --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.3.1"* ]]
}

@test "install specific ruby version" {
    export RUBY_VERSION="2.2.2"
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.2.2"* ]]
}

@test "deploy fails on invalid ruby version" {
    export RUBY_VERSION="ABC"
    run /var/lib/tsuru/deploy
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Unsuported ruby version."* ]]
}

@test "display supported versions if set" {
    export RUBY_VERSION="ABC"
    export SUPPORTED_VERSIONS="1.1.1, 1.2, 1.3"
    run /var/lib/tsuru/deploy
    [ "$status" -eq 1 ]
    [[ "$output" == *"Supported versions are: 1.1.1, 1.2, 1.3"* ]]
}
