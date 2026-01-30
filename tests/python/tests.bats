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

@test "use latest python version as default" {
    # Get the first LATEST_* version from the latest_versions.sh file
    source /var/lib/tsuru/python/latest_versions.sh
    LATEST_PYTHON_VERSIONS=($(grep -oE 'LATEST_[0-9]+="[^"]+"' /var/lib/tsuru/python/latest_versions.sh | cut -d'"' -f2 | sort -Vr))
    EXPECTED_VERSION="${LATEST_PYTHON_VERSIONS[0]}"

    run /var/lib/tsuru/deploy
    [[ "$output" == *"Using python version: ${EXPECTED_VERSION}"* ]]
    assert_success

    run python --version
    assert_success
    [[ "$output" == *"${EXPECTED_VERSION}"* ]]

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

@test "use latest python version as default with invalid .python-version" {
    # Get the first LATEST_* version from the latest_versions.sh file
    source /var/lib/tsuru/python/latest_versions.sh
    LATEST_PYTHON_VERSIONS=($(grep -oE 'LATEST_[0-9]+="[^"]+"' /var/lib/tsuru/python/latest_versions.sh | cut -d'"' -f2 | sort -Vr))
    EXPECTED_VERSION="${LATEST_PYTHON_VERSIONS[0]}"

    unset PYTHON_VERSION
    echo "xyz" > ${CURRENT_DIR}/.python-version
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Python version 'xyz' (.python-version file) is not supported"* ]]
    [[ "$output" == *"Using python version: ${EXPECTED_VERSION}"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"${EXPECTED_VERSION}"* ]]
}

@test "use latest python version as default with invalid PYTHON_VERSION" {
    # Get the first LATEST_* version from the latest_versions.sh file
    source /var/lib/tsuru/python/latest_versions.sh
    LATEST_PYTHON_VERSIONS=($(grep -oE 'LATEST_[0-9]+="[^"]+"' /var/lib/tsuru/python/latest_versions.sh | cut -d'"' -f2 | sort -Vr))
    EXPECTED_VERSION="${LATEST_PYTHON_VERSIONS[0]}"

    export PYTHON_VERSION=abc
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Python version 'abc' (PYTHON_VERSION environment variable) is not supported"* ]]
    [[ "$output" == *"Using python version: ${EXPECTED_VERSION}"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"${EXPECTED_VERSION}"* ]]
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
    export PYTHON_VERSION=3.14
    cp Pipfile Pipfile.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success
    
    # Should use Python 3.10 from Pipfile.lock
    [[ "$output" == *"Using python version: 3.10"* ]]
    [[ "$output" == *"(Pipfile.lock)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.10"* ]]

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack-python"* ]]
    rm ${CURRENT_DIR}/Pipfile*
}

@test "install from Pipfile.lock using python_full_version" {
    export PYTHON_VERSION=3.14
    cp Pipfile ${CURRENT_DIR}/
    cp Pipfile_fullversion.lock ${CURRENT_DIR}/Pipfile.lock

    run /var/lib/tsuru/deploy
    assert_success

    # Should use Python 3.10.5 from Pipfile.lock
    [[ "$output" == *"Using python version: 3.10.5"* ]]
    [[ "$output" == *"(Pipfile.lock)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.10.5"* ]]

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack-python"* ]]
    rm ${CURRENT_DIR}/Pipfile*
}

@test "install from Pipfile.lock with custom pipenv" {
    unset PYTHON_VERSION
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
    [[ "$output" == *"Using python version:"* ]]
    [[ "$output" == *"3.9."* ]]
    [[ "$output" == *"(PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.9."* ]]

    export PYTHON_VERSION=3.10.x
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using python version:"* ]]
    [[ "$output" == *"3.10."* ]]
    [[ "$output" == *"(PYTHON_VERSION environment variable (closest))"* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.10."* ]]

    # Test reuse of already installed version (use same 3.10.x pattern)
    export PYTHON_VERSION=3.10
    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using already installed python version:"* ]]
    [[ "$output" == *"3.10."* ]]
    run python --version

    assert_success
    [[ "$output" == *"3.10."* ]]

    export PYTHON_VERSION=3
    run /var/lib/tsuru/deploy
    assert_success

    [[ "$output" == *"Using python version:"* ]]
    [[ "$output" == *"3."* ]]
    [[ "$output" == *"(PYTHON_VERSION environment variable (closest))"* ]]
    
    # Get the actual installed version for verification
    run python --version
    assert_success
    [[ "$output" == *"3."* ]]

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

@test "install from poetry.lock" {
    unset PYTHON_VERSION
    cp pyproject.toml poetry.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success

    [[ "$output" == *"poetry.lock detected"* ]]
    [[ "$output" == *"Using latest poetry version"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3."* ]]

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack"* ]]
    rm ${CURRENT_DIR}/pyproject.toml ${CURRENT_DIR}/poetry.lock
}

@test "install from poetry.lock with custom poetry version" {
    unset PYTHON_VERSION
    export PYTHON_POETRY_VERSION=1.8.0
    cp pyproject.toml poetry.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success
    [[ "$output" == *"Using poetry version ==1.8.0"* ]]

    run poetry --version
    assert_success
    [[ "$output" == *"1.8.0"* ]]

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack"* ]]

    rm ${CURRENT_DIR}/pyproject.toml ${CURRENT_DIR}/poetry.lock
    unset PYTHON_POETRY_VERSION
}

@test "poetry.lock takes precedence over requirements.txt" {
    unset PYTHON_VERSION
    cp pyproject.toml poetry.lock ${CURRENT_DIR}/
    echo "alf==0.7.0" > ${CURRENT_DIR}/requirements.txt

    run /var/lib/tsuru/deploy
    assert_success

    [[ "$output" == *"poetry.lock detected"* ]]
    [[ "$output" != *"requirements.txt detected"* ]]

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack"* ]]
    [[ "$output" != *"alf"* ]]

    rm ${CURRENT_DIR}/pyproject.toml ${CURRENT_DIR}/poetry.lock ${CURRENT_DIR}/requirements.txt
}

@test "poetry.lock python version takes precedence over PYTHON_VERSION" {
    # pyproject.toml specifies python = "^3.10", so using 3.9 should fail
    # or poetry should take precedence and use 3.10 instead
    export PYTHON_VERSION=3.9.15
    cp pyproject.toml poetry.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success

    # Poetry should use Python 3.10 from poetry.lock, not 3.9.15 from env var
    [[ "$output" == *"poetry.lock detected"* ]]
    [[ "$output" == *"Using python version: 3.10"* ]]
    [[ "$output" == *"(poetry.lock)"* ]]

    pushd ${CURRENT_DIR}
    run python --version
    popd

    assert_success
    [[ "$output" == *"3.10"* ]]

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack"* ]]

    rm ${CURRENT_DIR}/pyproject.toml ${CURRENT_DIR}/poetry.lock
    unset PYTHON_VERSION
}

@test "install from poetry.lock with custom repository" {
    unset PYTHON_VERSION
    export POETRY_REPOSITORIES_ARTIFACTORY_URL=https://pypi.org/simple
    cp pyproject.toml poetry.lock ${CURRENT_DIR}/

    run /var/lib/tsuru/deploy
    assert_success

    [[ "$output" == *"poetry.lock detected"* ]]
    [[ "$output" == *"Configuring Poetry repository: artifactory -> https://pypi.org/simple"* ]]

    pushd ${CURRENT_DIR}
    run pip freeze
    popd

    assert_success
    [[ "$output" == *"msgpack"* ]]

    rm ${CURRENT_DIR}/pyproject.toml ${CURRENT_DIR}/poetry.lock
    unset POETRY_REPOSITORIES_ARTIFACTORY_URL
}