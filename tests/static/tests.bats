#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

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
