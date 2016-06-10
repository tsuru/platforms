#!/usr/bin/env bats

@test "installs build-essential" {
    dpkg -s build-essential | grep "install ok installed"
}

@test "installs sqlite3" {
    dpkg -s sqlite3 | grep "install ok installed"
}

@test "has runnable deploy script" {
    [ -x "/var/lib/tsuru/deploy" ]
}
