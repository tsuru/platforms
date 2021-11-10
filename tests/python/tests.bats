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

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "use python version 2.7 as default" {
    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: 2.7.18"* ]]
    assert_success

    run python --version
    assert_success
    [[ "$output" == *"2.7.18"* ]]

    run pip freeze
    assert_success
}

@test "parse python version from .python-version" {
    echo "3.5.10" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.5.10"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.5.10"* ]]
}

@test "parse python version from PYTHON_VERSION" {
    export PYTHON_VERSION=3.5.10
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.5.10"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.5.10"* ]]
    unset PYTHON_VERSION
}

@test "use python version 2.7 as default with invalid .python-version" {
    echo "xyz" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Python version 'xyz' (.python-version file) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.18"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"2.7.18"* ]]
}

@test "use python version 2.7 as default with invalid PYTHON_VERSION" {
    export PYTHON_VERSION=abc
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Python version 'abc' (PYTHON_VERSION environment variable) is not supported"* ]]
    [[ "$output" == *"Using python version: 2.7.18"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"2.7.18"* ]]
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
    export PYTHON_PIPENV_VERSION=2021.5.29
    cp Pipfile Pipfile.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using pipenv version ==2021.5.29"* ]]

    run pipenv --version
    assert_success
    [[ "$output" == *"version 2021.5.29"* ]]

    rm ${CURRENT_DIR}/Pipfile*
    unset PYTHON_PIPENV_VERSION
}

@test "change python version" {
    run /var/lib/tsuru/deploy
    assert_success
    run python --version

    assert_success
    [[ "$output" == *"2.7.18"* ]]

    export PYTHON_VERSION=3.5.10
    run /var/lib/tsuru/deploy
    assert_success
    run python --version

    assert_success
    [[ "$output" == *"3.5.10"* ]]
    unset PYTHON_VERSION
}

@test "reuses already installed python version" {
    echo "3.5.10" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.5.10"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.5.10"* ]]

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using already installed python version: 3.5.10"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.5.10"* ]]
}

@test "change python version to closest version" {
    export PYTHON_VERSION=3.6.x
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.6.12 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.6.12"* ]]

    export PYTHON_VERSION=3.7.x
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.7.9 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.7.9"* ]]

    export PYTHON_VERSION=3.7
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using already installed python version: 3.7.9"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.7.9"* ]]

    export PYTHON_VERSION=3.8.x
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.8.6 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.8.6"* ]]

    export PYTHON_VERSION=3.8
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using already installed python version: 3.8.6"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.8.6"* ]]

    export PYTHON_VERSION=3
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.9.0 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.9.0"* ]]

    export PYTHON_VERSION=3.5.x
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: 3.5.10 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.5.10"* ]]

    export PYTHON_VERSION=pypy2.7
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: pypy2.7-7.3.2 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"2.7"* ]]
    [[ "$output" == *"7.3.2"* ]]

    export PYTHON_VERSION=pypy3.6
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version: pypy3.6-7.3.2 (PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.6"* ]]
    [[ "$output" == *"7.3.2"* ]]

    export PYTHON_VERSION=pypy3
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using already installed python version: pypy3.6-7.3.2"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.6"* ]]
    [[ "$output" == *"7.3.2"* ]]

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
    echo "3.8" > ${CURRENT_DIR}/.python-version
    echo "uwsgi==2.0.18" > ${CURRENT_DIR}/requirements.txt

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
