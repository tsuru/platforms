#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PATH=/home/application/python/bin:${PATH}
    rm -rf /home/application/python/
}

@test "use python version 2.7 as default" {
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 2.7.17"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7.17"* ]]
}

@test "parse python version from .python-version" {
    echo "3.5.7" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.5.7"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.7"* ]]
}

@test "parse python version from PYTHON_VERSION" {
    export PYTHON_VERSION=3.5.7
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.5.7"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.7"* ]]
    unset PYTHON_VERSION
}

@test "use python version 2.7 as default with invalid .python-version" {
    echo "xyz" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Python version 'xyz' (.python-version file) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.17"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7.17"* ]]
}

@test "use python version 2.7 as default with invalid PYTHON_VERSION" {
    export PYTHON_VERSION=abc
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Python version 'abc' (PYTHON_VERSION environment variable) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.17"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7.17"* ]]
    unset PYTHON_VERSION
}

@test "install from setup.py" {
    cat <<EOF >${CURRENT_DIR}/setup.py
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
    [[ "$output" == *"2.7.17"* ]]

    export PYTHON_VERSION=3.5.7
    run /var/lib/tsuru/deploy
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.7"* ]]
    unset PYTHON_VERSION
}

@test "reuses already installed python version" {
    echo "3.5.7" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.5.7"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.7"* ]]

    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using already installed python version: 3.5.7"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.7"* ]]
}

@test "change python version to closest version" {
    export PYTHON_VERSION=3.6.x
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using python version: 3.6.10 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.6.10"* ]]

    export PYTHON_VERSION=3.7.x
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using python version: 3.7.6 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.7.6"* ]]

    export PYTHON_VERSION=3.7
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using already installed python version: 3.7.6"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.7.6"* ]]

    export PYTHON_VERSION=3
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using python version: 3.8.1 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.8.1"* ]]

    export PYTHON_VERSION=3.5.x
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using python version: 3.5.7 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.5.7"* ]]

    export PYTHON_VERSION=pypy2.7
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using python version: pypy2.7-7.2.0 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"2.7"* ]]
    [[ "$output" == *"7.2.0"* ]]

    export PYTHON_VERSION=pypy3.6
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using python version: pypy3.6-7.2.0 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.6"* ]]
    [[ "$output" == *"7.2.0"* ]]

    export PYTHON_VERSION=pypy3
    run /var/lib/tsuru/deploy
    [ "$status" -eq 0 ]
    [[ "$output" == *"Using already installed python version: pypy3.6-7.2.0"* ]]
    run python --version

    [ "$status" -eq 0 ]
    [[ "$output" == *"3.6"* ]]
    [[ "$output" == *"7.2.0"* ]]

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
