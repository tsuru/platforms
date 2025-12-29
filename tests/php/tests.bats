#!/usr/bin/env bats

# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

setup() {
    rm -rf /home/application/current && mkdir /home/application/current
    chown ubuntu /home/application/current
}

load 'bats-support-master/load'
load 'bats-assert-master/load'

@test "ensure composer version" {
    run composer_phar --version
    assert_success
    assert_output --partial "2.2.12"
}

@test "using default php(8.2) + apache-mod-php" {
    run /var/lib/tsuru/deploy
    run cat /home/application/current/Procfile
    assert_success
    [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start -DNO_DETACH "' ]
}

@test "sets correct ownership for generated Procfile allowing rewrites" {
    run /var/lib/tsuru/deploy
    assert_success
    run cat /home/application/current/Procfile
    assert_success
    [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start -DNO_DETACH "' ]
    run stat -c '%U' /home/application/current/Procfile
    assert_success
    [[ "$output" == "ubuntu" ]]
}

@test "using php8.2 + apache-mod-php" {
    cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 8.2
EOF
    run /var/lib/tsuru/deploy
    run ls /etc/apache2/mods-enabled/php*.conf
    assert_success
    [[ "$output" == "/etc/apache2/mods-enabled/php8.2.conf" ]]
}

@test "using invalid version backs to default_version" {
    cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 1000
EOF
    run /var/lib/tsuru/deploy
    run ls /etc/apache2/mods-enabled/php*.conf
    assert_success
    [[ "$output" == "/etc/apache2/mods-enabled/php8.2.conf" ]]
}

@test "using fpm and default frontend" {
    cat >/home/application/current/tsuru.yaml <<EOF
php:
  interpretor:
    name: fpm
EOF
    run /var/lib/tsuru/deploy
    run cat /home/application/current/Procfile
    [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start && /usr/sbin/php-fpm8.2 --fpm-config /etc/php/8.2/fpm/php-fpm.conf "' ]
}

@test "php 8.2 using fpm and default frontend" {
  cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 8.2
  interpretor:
    name: fpm
EOF
  run /var/lib/tsuru/deploy
  run cat /home/application/current/Procfile
  [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start && /usr/sbin/php-fpm8.2 --fpm-config /etc/php/8.2/fpm/php-fpm.conf "' ]
}

@test "php 8.3 using fpm and nginx as frontend" {
  cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 8.3
  interpretor:
    name: fpm
  frontend:
    name: nginx
EOF
  run /var/lib/tsuru/deploy
  run cat /home/application/current/Procfile
  [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/nginx && /usr/sbin/php-fpm8.3 --fpm-config /etc/php/8.3/fpm/php-fpm.conf "' ]
}

@test "php 8.2 using fpm, apache2 as frontend and mysql extension" {
  cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 8.2
  interpretor:
    name: fpm
    options:
      extensions:
        - mysql
  frontend:
    name: apache
EOF
  run /var/lib/tsuru/deploy
  run cat /home/application/current/Procfile
  [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start && /usr/sbin/php-fpm8.2 --fpm-config /etc/php/8.2/fpm/php-fpm.conf "' ]
  run bash -c 'dpkg -s php8.2-mysql | grep Status'
  [ "$output" == 'Status: install ok installed' ]
}

@test "install composer modules" {
    cat >/home/application/current/composer.json <<EOF
  {
      "require": {
          "ehime/hello-world": "*"
      }
  }
EOF
    run /var/lib/tsuru/deploy
    assert_success
    run sh -c "cd /home/application/current && composer_phar show"
    match="ehime/hello-world .+"
    [[ $output =~ $match ]]
}

@test "generate environment.conf for all php-fpm versions" {
  cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 8.2
  interpretor:
    name: fpm
EOF
    export FOO=1
    export BAR=2
    run /var/lib/tsuru/deploy
    for version in 8.2 8.2 8.3; do
        run bash -c "egrep '(FOO|BAR)' /etc/php/${version}/fpm/environment.conf | tr '\n' ' '"
        [ "$output" = "env[FOO] = 1 env[BAR] = 2 " ]
    done
}

@test "update-alternatives for php and phar" {
    for version in 8.2 8.2 8.3; do
      cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: ${version}
  interpretor:
    name: fpm
EOF
      run /var/lib/tsuru/deploy
      run bash -c "php --version | grep \"PHP ${version}\""
      [[ $output =~ ^PHP\ ${version}.+ ]]
      run bash -c "phar.phar version | grep 'PHP Version'"
      [[ $output =~ ^PHP\ Version:\ +${version}.+ ]]
      run bash -c "phar version | grep 'PHP Version'"
      [[ $output =~ ^PHP\ Version:\ +${version}.+ ]]
    done
}
