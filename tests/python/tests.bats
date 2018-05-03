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
    [[ "$output" == *"Using python version: 2.7.14 (default)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7.14"* ]]
}

@test "parse python version from .python-version" {
    echo "3.5.5" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.5.5 (.python-version file)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.5"* ]]
}

@test "parse python version from PYTHON_VERSION" {
    export PYTHON_VERSION=3.5.5
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.5.5 (PYTHON_VERSION environment variable)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.5"* ]]
    unset PYTHON_VERSION
}

@test "use python version 2.7 as default with invalid .python-version" {
    echo "xyz" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Python version 'xyz' (.python-version file) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.14 (default)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7.14"* ]]
}

@test "use python version 2.7 as default with invalid PYTHON_VERSION" {
    export PYTHON_VERSION=abc
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Python version 'abc' (PYTHON_VERSION environment variable) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.14 (default)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7.14"* ]]
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

@test "install from Pipfile.lock" {
    cp Pipfile Pipfile.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"msgpack-python"* ]]
    rm ${CURRENT_DIR}/Pipfile*
}

@test "change python version" {
    run /var/lib/tsuru/deploy
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7.14"* ]]

    export PYTHON_VERSION=3.5.5
    run /var/lib/tsuru/deploy
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.5"* ]]
    unset PYTHON_VERSION
}

@test "change python version to closest version" {
    export PYTHON_VERSION=3.6.1
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.6.5 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.6.5"* ]]

    export PYTHON_VERSION=3.5.1
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.5.5 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.5"* ]]

    export PYTHON_VERSION=pypy2.7
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: pypy2.7-5.10.0 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    echo "OUTPUT: xxx${output}xxx"
    [[ "$output" == *"2.7"* ]]
    [[ "$output" == *"5.10.0"* ]]

    export PYTHON_VERSION=pypy3.5
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: pypy3.5-5.10.1 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5"* ]]
    [[ "$output" == *"5.10.1"* ]]

    unset PYTHON_VERSION
}

@test "use default pip version" {
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using default pip version"* ]]
}

@test "set specific pip version" {
    export PYTHON_PIP_VERSION=9.0.3
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using pip version ==9.0.3"* ]]
    unset PYTHON_PIP_VERSION
}

@test "set pip version as range" {
    export PYTHON_PIP_VERSION="<10"
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using pip version <10"* ]]
    unset PYTHON_PIP_VERSION
}
