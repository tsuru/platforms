#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
}

@test "install erlang" {
    dpkg -s esl-erlang | grep "install ok installed"
}

@test "install specific erlang version" {
    export ERLANG_VERSION="19.2"
    run /var/lib/tsuru/deploy
    run bash -c 'cat /usr/lib/erlang/releases/*/OTP_VERSION | head -1'
    [ "$status" -eq 0 ]
    [[ "$output" == *"19.2"* ]]
}

@test "deploy fails on invalid erlang version" {
    export ERLANG_VERSION="ABC"
    run /var/lib/tsuru/deploy
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: erlang version ABC is not supported"* ]]
}

@test "install elixir" {
    dpkg -s elixir | grep "install ok installed"
}

@test "install specific elixir version" {
    export ELIXIR_VERSION="1.4.0"
    run /var/lib/tsuru/deploy
    run elixir --version
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Elixir 1.4.0"* ]]
}

@test "deploy fails on invalid elixir version" {
    export ELIXIR_VERSION="ABC"
    run /var/lib/tsuru/deploy
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: elixir version ABC is not supported"* ]]
}

@test "mix is installed" {
    run bash -c 'ls /usr/local/bin/mix | echo "ok installed"'
    [ "$status" -eq 0 ]
    [[ "$output" == "ok installed" ]]
}

@test "install specific mix version" {
    export ELIXIR_VERSION="1.5.2"
    run /var/lib/tsuru/deploy
    run /usr/local/bin/mix --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"Mix 1.5.2"* ]]
}
