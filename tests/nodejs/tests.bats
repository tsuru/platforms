#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir -p /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PATH=/home/ubuntu/.nvm_bin:$PATH
    su ubuntu
    rm -rf /home/ubuntu/.nvm_bin
    rm -rf /home/ubuntu/.nvm
}

@test "defaults yarn 0.27.5 if yarn.lock present" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "express": "3.x"
  }
}
EOF

    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"yarn.lock detected, using yarn to install node packages"* ]]

    run /home/ubuntu/.nvm_bin/yarn --version
    [[ "$output" == *"0.27.5"* ]]
}

@test "installs yarn from package.json" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "express": "3.x"
  },
  "engines": {
      "yarn": "0.24.6"
  }
}
EOF

    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"yarn.lock detected, using yarn to install node packages"* ]]

    run /home/ubuntu/.nvm_bin/yarn --version
    [[ "$output" == *"0.24.6"* ]]
}
