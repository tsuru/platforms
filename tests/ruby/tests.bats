#!/usr/bin/env bats

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

@test "install ruby version 2.2.3 as default" {
    run /home/application/ruby/bin/ruby --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.2.3"* ]]
}
