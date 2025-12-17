#!/usr/bin/env bats

# Copyright 2025 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
    export CURRENT_DIR=/home/application/current
    export PATH=/home/application/python/bin:${PATH}
    rm -rf /home/application/python/
}

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "use python version 3.14.2 as default" {
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.14.2"* ]]
    assert_success

    run python --version
    assert_success
    [[ "$output" == *"3.14.2"* ]]

    run pip freeze
    assert_success
}

@test "use python version 3.11 as default" {
    export PYTHON_VERSION_DEFAULT=3.11.3
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.11.3"* ]]
    assert_success

    run python --version
    assert_success
    [[ "$output" == *"3.11.3"* ]]

    run pip freeze
    assert_success
}

@test "set 3.9 as default python version" {
    export PYTHON_VERSION_DEFAULT=3.9.15
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 3.9.15"* ]]
    assert_success

    run python --version
    assert_success
    [[ "$output" == *"3.9.15"* ]]

    run pip freeze
    assert_success
}

@test "parse python version from .python-version" {
    echo "3.9.15" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.9.15"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.9.15"* ]]
}

@test "testing python compiled using dynamic shared lib" {
    echo "3.11.0" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.11.0"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.11.0"* ]]
}


@test "parse python version from PYTHON_VERSION" {
    export PYTHON_VERSION=3.9.15
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.9.15"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.9.15"* ]]
    unset PYTHON_VERSION
}

@test "use python version 3.14.2 as default with invalid .python-version" {
    export PYTHON_VERSION=3.11.3
    echo "xyz" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Python version 'xyz' (.python-version file) is not supported"* ]]
    [[ "$output" == *"Using python version: 3.14.2"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.14.2"* ]]
}

@test "use python version 3.14.2 as default with invalid PYTHON_VERSION" {
    export PYTHON_VERSION=abc
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Python version 'abc' (PYTHON_VERSION environment variable) is not supported"* ]]
    [[ "$output" == *"Using python version: 3.14.2"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.14.2"* ]]
    unset PYTHON_VERSION
}

@test "install from setup.py" {
    cat <<EOF >${CURRENT_DIR}/setup.py
from setuptools import setup
setup(name='tsr-deploy-test', install_requires=[ 'alf==0.7.0' ],)
EOF
    run /var/lib/tsuru/deploy
    assert_success

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"alf"* ]]
    rm ${CURRENT_DIR}/setup.py
}

@test "install from requirements" {
    echo "msgpack-python==0.4.8" > ${CURRENT_DIR}/requirements.txt

    run /var/lib/tsuru/deploy
    assert_success

    pushd ${CURRENT_DIR}
    run pip freeze
    popd
    assert_success
    [[ "$output" == *"msgpack-python"* ]]
    rm ${CURRENT_DIR}/requirements.txt
}

@test "install from Pipfile.lock" {
    cp Pipfile Pipfile.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack-python"* ]]
    rm ${CURRENT_DIR}/Pipfile*
}

@test "install from Pipfile.lock with custom pipenv" {
    export PYTHON_PIPENV_VERSION=2023.12.1
    cp Pipfile Pipfile.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using pipenv version ==2023.12.1"* ]]

    run pipenv --version
    assert_success
    [[ "$output" == *"version 2023.12.1"* ]]

    rm ${CURRENT_DIR}/Pipfile*
    unset PYTHON_PIPENV_VERSION
}

@test "change python version" {
    export PYTHON_VERSION=3.11.3
    run /var/lib/tsuru/deploy
    assert_success
    run python --version

    assert_success
    [[ "$output" == *"3.11.3"* ]]

    export PYTHON_VERSION=3.10.5
    run /var/lib/tsuru/deploy
    assert_success
    run python --version

    assert_success
    [[ "$output" == *"3.10.5"* ]]
    unset PYTHON_VERSION
}

@test "reuses already installed python version" {
    echo "3.9.15" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.9.15"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.9.15"* ]]

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using already installed python version: 3.9.15"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.9.15"* ]]
}

@test "change python version to closest version" {
    export PYTHON_VERSION=3.9.x
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.9.25 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.9.25"* ]]

    export PYTHON_VERSION=3.10.x
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.10.19 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.10.19"* ]]

    export PYTHON_VERSION=3.10
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using already installed python version: 3.10.19"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.10.19"* ]]

    export PYTHON_VERSION=3
    run /var/lib/tsuru/deploy
    assert_success

    [[ "$output" == *"Using python version: 3.14.2 (PYTHON_VERSION environment variable (closest))"* ]]
    export PYTHON_VERSION=3.14.2
    run python --version

    assert_success
    [[ "$output" == *"3.14.2"* ]]

    unset PYTHON_VERSION
}

@test "use default pip version" {
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using default pip version"* ]]
}

@test "set specific pip version" {
    export PYTHON_PIP_VERSION=9.0.3
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using pip version ==9.0.3"* ]]
    unset PYTHON_PIP_VERSION
}

@test "set pip version as range" {
    export PYTHON_PIP_VERSION="<10"
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using pip version <10"* ]]
    unset PYTHON_PIP_VERSION
}

@test "can install uwsgi with python 3" {
    echo "3.10" > ${CURRENT_DIR}/.python-version
    echo "uwsgi==2.0.26" > ${CURRENT_DIR}/requirements.txt

    run /var/lib/tsuru/deploy
    assert_success

    pushd ${CURRENT_DIR}
    run pip freeze
    popd
    assert_success
    [[ "$output" == *"uWSGI"* ]]
    rm ${CURRENT_DIR}/requirements.txt
    rm ${CURRENT_DIR}/.python-version
}
