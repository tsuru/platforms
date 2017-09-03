#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PYENV_ROOT=/var/lib/pyenv
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    pyenv uninstall --force app_env
}

@test "use python version 2.7 as default" {
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 2.7.13 (default)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7"* ]]
}

@test "parse python version from .python-version" {
    echo "3.5.3" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.5.3 (.python-version file)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5"* ]]
}

@test "parse python version from PYTHON_VERSION" {
    export PYTHON_VERSION=3.6.1
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.6.1 (PYTHON_VERSION environment variable)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.6"* ]]
    unset PYTHON_VERSION
}

@test "use python version 2.7 as default with invalid .python-version" {
    echo "xyz" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Python version 'xyz' (.python-version file) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.13 (default)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7"* ]]
}

@test "use python version 2.7 as default with invalid PYTHON_VERSION" {
    export PYTHON_VERSION=abc
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Python version 'abc' (PYTHON_VERSION environment variable) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.13 (default)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7"* ]]
    unset PYTHON_VERSION
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

@test "change python version" {
    run /var/lib/tsuru/deploy
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7"* ]]

    export PYTHON_VERSION=3.6.1
    run /var/lib/tsuru/deploy
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.6"* ]]
    unset PYTHON_VERSION
}
