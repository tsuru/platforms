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
    [[ "$output" == *"ERROR: ruby version ABC is not supported."* ]]
}

@test "display supported versions if set" {
    export RUBY_VERSION="ABC"
    export SUPPORTED_VERSIONS="1.1.1, 1.2, 1.3"
    run /var/lib/tsuru/deploy
    [ "$status" -eq 1 ]
    [[ "$output" == *"Supported versions are: 1.1.1, 1.2, 1.3"* ]]
}

@test "parse ruby version from .ruby-version" {
    export CURRENT_DIR=$(pwd)
    echo "ruby-2.1.2" > .ruby-version
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.1.2"* ]]
    rm .ruby-version
}

@test "bundle install when provide Gemfile" {
    export CURRENT_DIR=$(pwd)
    echo "ruby-2.1.2" > .ruby-version
    echo "source 'https://rubygems.org'" > Gemfile
    echo "gem 'hello-world', '1.2.0'" >> Gemfile
    cat <<EOF>Gemfile.lock
GEM
  remote: https://rubygems.org/
  specs:
    hello-world (1.2.0)

PLATFORMS
  ruby

DEPENDENCIES
  hello-world (= 1.2.0)

BUNDLED WITH
   1.13.7
EOF

    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing hello-world"* ]]
}

@test "do not try to reinstall a gem already in vendor directory" {
    export CURRENT_DIR=$(pwd)
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using hello-world"* ]]
}
