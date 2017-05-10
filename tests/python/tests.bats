#!/usr/bin/env bats

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PYENV_ROOT=/var/lib/pyenv
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

@test "use python version 3.5 as default" {

    run /var/lib/tsuru/deploy

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5"* ]]
}

@test "parse python version from .python-version" {
    echo "2.7.13" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7"* ]]
    rm ${CURRENT_DIR}/.python-version
}

@test "install from setup.py" {
    cat <<EOF>${CURRENT_DIR}/setup.py
from setuptools import setup
setup(name='tsr-deploy-test', install_requires=[ 'alf==0.7.0' ],)
EOF
    run /var/lib/tsuru/deploy

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"alf"* ]]
    rm ${CURRENT_DIR}/setup.py
}

@test "install from requirements" {
    echo "msgpack-python==0.4.8" > ${CURRENT_DIR}/requirements.txt

    run /var/lib/tsuru/deploy

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"msgpack-python"* ]]
    rm ${CURRENT_DIR}/requirements.txt
}
