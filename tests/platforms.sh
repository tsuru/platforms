#!/bin/bash -el

# Copyright 2016 platforms authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

cd "$(dirname "$0")"

function add_platform() {
	platform=$1
	echo "adding platform $platform..."
	output_file="/tmp/platform-update-${platform}"
	set +e
	tsuru platform-add $platform | tee $output_file
	result=$?
	set -e
	if [[ $result != 0 ]]; then
		if [[ $(tail -n1 $output_file) != "Error: Duplicate platform" ]]; then
			echo "error adding platform $platform"
			exit $result
		fi
	fi
}

function test_platform() {
	platform=$1
	app_name=app-${platform}
	app_dir=../examples/${platform}
	echo "testing platform ${platform} with app ${app_name}..."

    tsuru app-create ${app_name} ${platform} -o theonepool -t admin;


	echo "Running deploy with app-deploy..."
    pushd ${app_dir}
	tsuru app-deploy -a ${app_name} .
    popd

    host=`tsuru app-info -a ${app_name} | grep Address | awk '{print $2}'`

	set +e
	for i in `seq 1 5`
	do
		output=`curl -m 5 -fsSN $host`
		if [ $? == 0 ]
		then
			break
		fi
		sleep 5
	done
	msg=`echo $output | grep -q "Hello world from tsuru" || echo "ERROR: Platform $platform - Wrong output: $output"`
	set -e

	tsuru app-remove -ya ${app_name}

	if [ "$msg" != "" ]
	then
		echo >&2 $msg
		exit 1
	fi
}

function tsuru_login {
	yes $2 | tsuru login $1
}

tsuru_login admin@example.com admin123

platforms=$(ls ../examples/ | cut -f1 -d'/' | cut -f1 -d'@')

for platform in $platforms
do
	add_platform $platform
	test_platform $platform
done
