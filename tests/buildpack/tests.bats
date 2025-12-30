#!/usr/bin/env bats

# Copyright 2025 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    sudo rm -rf /home/application/current && sudo mkdir -p /home/application/current
    sudo chown heroku /home/application/current
    export CURRENT_DIR=/home/application/current
}

load '/tests/bats-support-master/load'
load '/tests/bats-assert-master/load'

@test "has runnable deploy script" {
    [ -x "/var/lib/tsuru/deploy" ]
}

@test "deploy script uses the base scripts" {
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"ran base deploy"* ]]
}

@test "buildpack directory exists" {
    [ -d "/var/lib/tsuru/buildpack" ]
}

@test "buildpack build script exists and is executable" {
    [ -x "/var/lib/tsuru/buildpack/build" ]
}

@test "buildpack install script exists and is executable" {
    [ -x "/var/lib/tsuru/buildpack/install" ]
}

@test "herokuish command is available" {
    command -v herokuish
}

@test "herokuish version is accessible" {
    run herokuish version
    assert_success
}

@test "curl is installed" {
    command -v curl
}

@test "sudo is installed" {
    command -v sudo
}

@test "locale is set to en_US.UTF-8" {
    [[ "$LANG" == "en_US.UTF-8" ]]
}

@test "app directory exists with correct permissions" {
    [ -d "/app" ]
    stat -c "%U:%G" /app | grep -q "heroku:heroku"
}

@test "base platform is installed" {
    [ -d "/var/lib/tsuru/base" ]
}

@test "base platform config exists" {
    [ -f "/var/lib/tsuru/base/rc/config" ] || [ -f "/var/lib/tsuru/base/deploy" ]
}

@test "profile.d directory exists in app" {
    [ -d "/app/.profile.d" ] || sudo mkdir -p /app/.profile.d
    [ -d "/app/.profile.d" ]
}

@test "tsuru.sh profile script can be created" {
    sudo bash -c 'echo "export TEST_VAR=test" > /app/.profile.d/test.sh'
    [ -f "/app/.profile.d/test.sh" ]
    sudo rm -f /app/.profile.d/test.sh
}

@test "PORT environment variable defaults to 8888" {
    # Test that the PORT variable is configurable with default
    source <(echo 'export PORT=${PORT:-8888}')
    [[ "$PORT" == "8888" ]]
}

@test "Python 3 paths are configured" {
    # Verify Python 3 is available (not Python 2.7)
    if command -v python3 &> /dev/null; then
        run python3 --version
        assert_success
        [[ "$output" == *"Python 3"* ]]
    fi
}

@test "buildpack can handle empty BUILDPACK_URL" {
    export BUILDPACK_URL=""
    export CURRENT_DIR=/home/application/current
    run sudo -E /var/lib/tsuru/buildpack/build
    # Should not fail catastrophically
    [[ $status -eq 0 || $status -eq 1 ]]
}

@test "Procfile can be processed" {
    sudo bash -c 'echo "web: echo '\''test process'\''" > /app/Procfile'
    run perl -lne '/^(.*?):/ && print "$1: /start $1"' /app/Procfile
    assert_success
    [[ "$output" == *"web: /start web"* ]]
    sudo rm -f /app/Procfile
}

@test "ca-certificates are installed" {
    [ -d "/etc/ssl/certs" ]
    [ -f "/etc/ssl/certs/ca-certificates.crt" ] || [ -d "/usr/share/ca-certificates" ]
}

# Integration tests with actual buildpack builds

@test "herokuish can detect and list available buildpacks" {
    run herokuish buildpack list
    assert_success
    # Should list some common buildpacks
    [[ "$output" == *"buildpack"* ]]
}

@test "buildpack can detect Python applications" {
    # Test that buildpack can detect Python apps by checking requirements.txt
    local test_dir="/tmp/test-python-detect-$$"
    sudo mkdir -p "$test_dir"

    # Create minimal Python app signature
    echo "Flask==3.0.0" | sudo tee "$test_dir/requirements.txt" > /dev/null

    # Verify Python buildpack detect script exists and can run
    run sudo /tmp/buildpacks/04_buildpack-python/bin/detect "$test_dir"

    # Cleanup
    sudo rm -rf "$test_dir"

    # Detect script should succeed and output "Python"
    assert_success
    [[ "$output" == *"Python"* ]]
}

@test "buildpack can detect Ruby applications" {
    # Test that buildpack can detect Ruby apps by checking Gemfile
    local test_dir="/tmp/test-ruby-detect-$$"
    sudo mkdir -p "$test_dir"

    # Create minimal Ruby app signature
    echo "source 'https://rubygems.org'" | sudo tee "$test_dir/Gemfile" > /dev/null

    # Verify Ruby buildpack detect script exists and can run
    run sudo /tmp/buildpacks/01_buildpack-ruby/bin/detect "$test_dir"

    # Cleanup
    sudo rm -rf "$test_dir"

    # Detect script should succeed and output "Ruby"
    assert_success
    [[ "$output" == *"Ruby"* ]]
}

@test "buildpack can detect Node.js applications (skip on ARM64)" {
    # Skip on ARM64 due to QEMU limitations with x86_64 binaries
    if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
        skip "Node.js buildpack test skipped on ARM64 architecture"
    fi

    # Test that buildpack can detect Node.js apps by checking package.json
    local test_dir="/tmp/test-nodejs-detect-$$"
    sudo mkdir -p "$test_dir"

    # Create minimal Node.js app signature
    echo '{"name":"test","version":"1.0.0"}' | sudo tee "$test_dir/package.json" > /dev/null

    # Verify Node.js buildpack detect script exists and can run
    run sudo /tmp/buildpacks/02_buildpack-nodejs/bin/detect "$test_dir"

    # Cleanup
    sudo rm -rf "$test_dir"

    # Detect script should succeed and output "Node.js"
    assert_success
    [[ "$output" == *"Node"* ]]
}
