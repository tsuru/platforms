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

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "installs build-essential" {
    dpkg -s build-essential | grep "install ok installed"
}

@test "install ruby version 3.1.6 as default" {
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    assert_success
    [[ "$output" == *"3.1.6"* ]]
}

@test "install specific ruby version" {
    export RUBY_VERSION="3.2.1"
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    assert_success
    [[ "$output" == *"3.2.1"* ]]
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
    echo "ruby-3.2.2" > ${CURRENT_DIR}/.ruby-version
    run /var/lib/tsuru/deploy
    run /home/application/ruby/bin/ruby --version
    assert_success
    [[ "$output" == *"3.2.2"* ]]
    rm ${CURRENT_DIR}/.ruby-version
}

@test "detect ruby version 3.2.1 on Gemfile" {
    echo "source 'https://rubygems.org'" > ${CURRENT_DIR}/Gemfile
    echo "gem 'hello-world', '1.2.0'" >> ${CURRENT_DIR}/Gemfile
    echo "ruby '3.2.1'" >> ${CURRENT_DIR}/Gemfile
    cat <<EOF>${CURRENT_DIR}/Gemfile.lock
GEM
  remote: https://rubygems.org/
  specs:
    hello-world (1.2.0)

PLATFORMS
  ruby

DEPENDENCIES
  hello-world (= 1.2.0)

RUBY VERSION
   ruby 3.2.1p146

BUNDLED WITH
   2.0.1
EOF

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"-- Using ruby version: 3.2.1 --"* ]]
}

@test "bundle install when provide Gemfile and reuse already installed gem" {
    echo "ruby-3.2.2" > ${CURRENT_DIR}/.ruby-version
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
   2.0.1
EOF

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Installing hello-world"* ]]
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using hello-world"* ]]
    run /home/application/ruby/bin/bundler --version
    assert_success
    assert_output --partial "Bundler version 2."
}

@test "using bundle inside Gemfile.lock and ignore bundle vendoring version for ruby >= 2.6" {
    echo "ruby-3.2.1" > ${CURRENT_DIR}/.ruby-version
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
   2.0.1
EOF

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Installing hello-world"* ]]
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using hello-world"* ]]
    run /home/application/ruby/bin/bundler --version
    assert_success
    assert_output --partial "Bundler version 2."
}

@test "bundle install when provide Gemfile with no bundled with section" {
    echo "ruby-3.1.2" > ${CURRENT_DIR}/.ruby-version
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
    assert_success
    [[ "$output" == *"Installing hello-world"* ]]
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using hello-world"* ]]
    run /home/application/ruby/bin/bundler --version
    assert_success
    assert_output --partial "Bundler version 2."
}
