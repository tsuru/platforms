#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/ruby
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PATH=/home/application/ruby/bin:${PATH}
}

@test "installs ruby" {
    dpkg -s ruby | grep "install ok installed"
}

@test "installs build-essential" {
    dpkg -s build-essential | grep "install ok installed"
}

@test "install ruby version 2.4.6 as default" {
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.4.6"* ]]
}

@test "install specific ruby version" {
    export RUBY_VERSION="2.6.3"
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.6.3"* ]]
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
    echo "ruby-2.5.5" > ${CURRENT_DIR}/.ruby-version
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.5.5"* ]]
    rm ${CURRENT_DIR}/.ruby-version
}

@test "install bundler version <2 when ruby version < 2.3.0" {
    export RUBY_VERSION="2.2.2"
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/bundler --version
    [ "$status" -eq 0 ]
    [[ "$output" == "Bundler version 1."* ]]
}

@test "install bundler version >=2 when ruby version >= 2.3.0" {
    export RUBY_VERSION="2.3.0"
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/bundler --version
    [ "$status" -eq 0 ]
    [[ "$output" == "Bundler version 2."* ]]
}

@test "using bundler within ruby package when version >=2.6.0" {
    export RUBY_VERSION="2.6.0"
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/bundler --version
    [ "$status" -eq 0 ]
    [[ "$output" == "Bundler version "* ]]
}

@test "bundle install when provide Gemfile and reuse already installed gem" {
    echo "ruby-2.1.2" > ${CURRENT_DIR}/.ruby-version
    echo "source 'https://rubygems.org'" > ${CURRENT_DIR}/Gemfile
    echo "gem 'hello-world', '1.2.0'" >> ${CURRENT_DIR}/Gemfile
    cat <<EOF>${CURRENT_DIR}/Gemfile.lock
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
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using hello-world"* ]]
    run /home/application/ruby/bin/bundler --version
    [ "$status" -eq 0 ]
    [[ "$output" == "Bundler version 1.13.7" ]]
}

@test "bundle install when provide Gemfile with no bundled with section" {
    echo "ruby-2.1.2" > ${CURRENT_DIR}/.ruby-version
    echo "source 'https://rubygems.org'" > ${CURRENT_DIR}/Gemfile
    echo "gem 'hello-world', '1.2.0'" >> ${CURRENT_DIR}/Gemfile
    cat <<EOF>${CURRENT_DIR}/Gemfile.lock
GEM
  remote: https://rubygems.org/
  specs:
    hello-world (1.2.0)

PLATFORMS
  ruby

DEPENDENCIES
  hello-world (= 1.2.0)
EOF

    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing hello-world"* ]]
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using hello-world"* ]]
    run /home/application/ruby/bin/bundler --version
    [ "$status" -eq 0 ]
    [[ "$output" == "Bundler version 1."* ]]
}
