#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

@test "has runnable deploy script" {
    [ -x "/var/lib/tsuru/deploy" ]
}

@test "deploy script uses the base scripts" {
    run /var/lib/tsuru/deploy
    [[ "$output" == *"ran base deploy"* ]]
}
