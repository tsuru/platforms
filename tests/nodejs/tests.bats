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

@test "defaults yarn 1.3.2 if yarn.lock present" {
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
    [[ "$output" == *"1.3.2"* ]]
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

@test "breaks with invalid dependencies" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "express": "999"
  },
  "engines": {
      "yarn": "0.24.6"
  }
}
EOF

    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -ne 0 ]
    [[ "$output" == *"Couldn't find any versions for \"express\" that matches \"999\""* ]]
}

@test "works with yarn versions without support to --non-interactive flag" {
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
      "yarn": "0.17.0"
  }
}
EOF

    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"yarn.lock detected, using yarn to install node packages"* ]]

    run /home/ubuntu/.nvm_bin/yarn --version
    [[ "$output" == *"0.17.0"* ]]
}

@test "reads node version from .nvmrc" {
    echo "v8.9.0" >${CURRENT_DIR}/.nvmrc
    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    run node --version
    [[ "$output" == "v8.9.0" ]]
}

@test "reads node version from .node-version" {
    echo "v8.9.1" >${CURRENT_DIR}/.node-version
    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    run node --version
    [[ "$output" == "v8.9.1" ]]
}

@test "reads node version from package.json" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "engines": {
      "node": "v8.9.2"
  }
}
EOF
    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    run node --version
    [[ "$output" == "v8.9.2" ]]
}

@test "breaks with invalid node version" {
    echo "myinvalidversion" >${CURRENT_DIR}/.node-version
    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -ne 0 ]
    [[ "$output" == *"Version 'myinvalidversion' not found"* ]]
    [[ "$output" == *"ERROR: \`nvm install \"myinvalidversion\"\` returned exit status"* ]]
}

@test "doesn't install dev dependencies with npm" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "is-sorted": "1.x"
  },
  "devDependencies": {
    "leftpad": "0.0.1"
  }
}
EOF

    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -d ${CURRENT_DIR}/node_modules/is-sorted ]
    [ ! -d ${CURRENT_DIR}/node_modules/leftpad ]
}

@test "doesn't install dev dependencies with yarn" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "is-sorted": "1.x"
  },
  "devDependencies": {
    "leftpad": "0.0.1"
  }
}
EOF

    touch ${CURRENT_DIR}/yarn.lock
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -d ${CURRENT_DIR}/node_modules/is-sorted ]
    [ ! -d ${CURRENT_DIR}/node_modules/leftpad ]
}

@test "doesn't install dev dependencies with npm and NPM_CONFIG_PRODUCTION=true" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "is-sorted": "1.x"
  },
  "devDependencies": {
    "leftpad": "0.0.1"
  }
}
EOF

    NPM_CONFIG_PRODUCTION=true run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -d ${CURRENT_DIR}/node_modules/is-sorted ]
    [ ! -d ${CURRENT_DIR}/node_modules/leftpad ]
}

@test "doesn't install dev dependencies with yarn and NPM_CONFIG_PRODUCTION=true" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "is-sorted": "1.x"
  },
  "devDependencies": {
    "leftpad": "0.0.1"
  }
}
EOF

    touch ${CURRENT_DIR}/yarn.lock
    NPM_CONFIG_PRODUCTION=true run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -d ${CURRENT_DIR}/node_modules/is-sorted ]
    [ ! -d ${CURRENT_DIR}/node_modules/leftpad ]
}

@test "installs dev dependencies with npm and NPM_CONFIG_PRODUCTION=false" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "is-sorted": "1.x"
  },
  "devDependencies": {
    "leftpad": "0.0.1"
  }
}
EOF

    NPM_CONFIG_PRODUCTION=false run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -d ${CURRENT_DIR}/node_modules/is-sorted ]
    [ -d ${CURRENT_DIR}/node_modules/leftpad ]
}

@test "installs dev dependencies with yarn and NPM_CONFIG_PRODUCTION=false" {
    cat <<EOF>>${CURRENT_DIR}/package.json
{
  "name": "hello-world",
  "description": "hello world test on tsuru",
  "version": "0.0.1",
  "private": true,
  "dependencies": {
    "is-sorted": "1.x"
  },
  "devDependencies": {
    "leftpad": "0.0.1"
  }
}
EOF

    touch ${CURRENT_DIR}/yarn.lock
    NPM_CONFIG_PRODUCTION=false run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]

    [ -d ${CURRENT_DIR}/node_modules/is-sorted ]
    [ -d ${CURRENT_DIR}/node_modules/leftpad ]
}

@test "replaces the default npmjs.org urls with NPM_REGISTRY" {
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
    cat <<EOF>>${CURRENT_DIR}/package-lock.json
https://registry.npmjs.org/express
EOF
    export NPM_REGISTRY=my-registry.example.com
    run /var/lib/tsuru/deploy
    [ `cat ${CURRENT_DIR}/package-lock.json` == "my-registry.example.com/express" ]
}

@test "replaces the default yarnpkg.com urls with NPM_REGISTRY" {
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
    cat <<EOF>>${CURRENT_DIR}/yarn.lock
https://registry.yarnpkg.com/express
EOF
    export NPM_REGISTRY=my-registry.example.com
    run /var/lib/tsuru/deploy
    [ `cat ${CURRENT_DIR}/yarn.lock` == "my-registry.example.com/express" ]
}
