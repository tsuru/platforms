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

@test "using default php(5.6) + apache-mod-php" {
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

@test "using php7.1 + apache-mod-php" {
    cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 7.1
EOF
    run /var/lib/tsuru/deploy
    run ls /etc/apache2/mods-enabled/php*.conf
    assert_success
    [[ "$output" == "/etc/apache2/mods-enabled/php7.1.conf" ]]
}

@test "using invalid version backs to default_version" {
    cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 1000
EOF
    run /var/lib/tsuru/deploy
    run ls /etc/apache2/mods-enabled/php*.conf
    assert_success
    [[ "$output" == "/etc/apache2/mods-enabled/php5.6.conf" ]]
}

@test "using old fpm format and default frontend" {
    cat >/home/application/current/tsuru.yaml <<EOF
php:
  interpretor:
    name: fpm54
EOF
    run /var/lib/tsuru/deploy
    run cat /home/application/current/Procfile
    [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start && /usr/sbin/php-fpm5.6 --fpm-config /etc/php/5.6/fpm/php-fpm.conf "' ]
}

@test "php 7.0 using fpm and default frontend" {
  cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 7.0
  interpretor:
    name: fpm
EOF
  run /var/lib/tsuru/deploy
  run cat /home/application/current/Procfile
  [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start && /usr/sbin/php-fpm7.0 --fpm-config /etc/php/7.0/fpm/php-fpm.conf "' ]
}

@test "php 7.0 using fpm and nginx as frontend" {
  cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 7.0
  interpretor:
    name: fpm
  frontend:
    name: nginx
EOF
  run /var/lib/tsuru/deploy
  run cat /home/application/current/Procfile
  [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/nginx && /usr/sbin/php-fpm7.0 --fpm-config /etc/php/7.0/fpm/php-fpm.conf "' ]
}

@test "php 7.1 using fpm, apache2 as frontend and old php5-mysql module format" {
  cat >/home/application/current/tsuru.yaml <<EOF
php:
  version: 7.1
  interpretor:
    name: fpm
    options:
      extensions:
        - php5-mysql
  frontend:
    name: apache
EOF
  run /var/lib/tsuru/deploy
  run cat /home/application/current/Procfile
  [ "$output" == 'web: /bin/bash -lc "sudo -E /usr/sbin/apache2 -d /etc/apache2 -k start && /usr/sbin/php-fpm7.1 --fpm-config /etc/php/7.1/fpm/php-fpm.conf "' ]
  run bash -c 'dpkg -s php7.1-mysql | grep Status'
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
  version: 7.1
  interpretor:
    name: fpm
EOF
    export FOO=1
    export BAR=2
    run /var/lib/tsuru/deploy
    for version in 5.6 7.0 7.1; do
        run bash -c "egrep '(FOO|BAR)' /etc/php/${version}/fpm/environment.conf | tr '\n' ' '"
        [ "$output" = "env[BAR] = 2 env[FOO] = 1 " ]
    done
}

@test "update-alternatives for php and phar" {
    for version in 5.6 7.0 7.1; do
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
