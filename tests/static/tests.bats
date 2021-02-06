#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "installs nginx" {
    dpkg -s nginx | grep "install ok installed"
}

@test "sets up a default nginx conf" {
    [ -f /etc/nginx/nginx.conf ]
    [ -s /etc/nginx/nginx.conf ]
}

@test "sets up a default Procfile" {
    [ -f /var/lib/tsuru/default/Procfile ]
    [ -s /var/lib/tsuru/default/Procfile ]
}

@test "deploys an customized nginx package" {
    export NGINX_PKG="nginx-extras"
    run /var/lib/tsuru/deploy
    assert_success
    dpkg -s nginx-extras | grep "install ok installed"
}

@test "deploys fail on invalid nginx package" {
    export NGINX_PKG="invalid-nginx"
    run /var/lib/tsuru/deploy
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR: Invalid nginx package invalid-nginx."* ]]
}

@test "deploy installs default nginx if env not set" {
    export NGINX_PKG=""
    run /var/lib/tsuru/deploy
    assert_success
    dpkg -s nginx | grep "install ok installed"
}
