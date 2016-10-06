# -*- coding: utf-8 -*-

# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

import os
import shutil
import subprocess
from utils import replace

class Interpretor(object):
    def __init__(self, configuration, application):
        self.configuration = configuration
        self.application = application
        self.socket_address = None

    def configure(self, frontend):
        # If frontend supports unix sockets, use them by default
        self.socket_address = 'unix:/var/run/php5/fpm.sock'
        if not frontend.supports_unix_proxy():
            self.socket_address = '127.0.0.1:9000'

        # Clear pre-configured pools
        map(os.unlink, [os.path.join('/etc/php5/fpm/pool.d', f) for f in os.listdir('/etc/php5/fpm/pool.d')])
        templates_mapping = {
            'pool.conf': '/etc/php5/fpm/pool.d/tsuru.conf',
            'php-fpm.conf': '/etc/php5/fpm/php-fpm.conf'
        }

        for template, target in templates_mapping.iteritems():
            shutil.copyfile(
                os.path.join(self.application.get('source_directory'), 'php', 'interpretor', 'fpm5', template),
                target
            )

        # Replace pool listen address
        listen_address = self.socket_address
        if listen_address[0:5] == 'unix:':
            listen_address = listen_address[5:]

        replace(templates_mapping['pool.conf'], '_FPM_POOL_LISTEN_', listen_address)

        if 'ini_file' in self.configuration:
            shutil.copyfile(
                os.path.join(self.application.get('directory'), self.configuration.get('ini_file')),
                '/etc/php5/fpm/php.ini'
            )

        # Clean and touch some files
        for file_path in ['/var/log/php5-fpm.log', '/etc/php5/fpm/environment.conf']:
            open(file_path, 'a').close()
            os.system('chown %s %s' % (self.application.get('user'), file_path))

        # Clean run directory
        run_directory = '/var/run/php5'
        if not os.path.exists(run_directory):
            os.makedirs(run_directory)

        # Fix user rights
        os.system('chown -R %s /etc/php5/fpm /var/run/php5' % self.application.get('user'))

    def get_address(self):
        return self.socket_address

    def setup_environment(self):
        target = '/etc/php5/fpm/environment.conf'

        with open(target, 'w') as f:
            for (k, v) in self.application.get('env', {}).items():
                if v:
                    f.write('env[%s] = %s\n' % (k, v))

    def get_startup_cmd(self):
        return '/usr/sbin/php5-fpm --fpm-config /etc/php5/fpm/php-fpm.conf'

    def get_packages_extensions(self):
        packages = []
        if 'extensions' in self.configuration:
            for extension in self.configuration.get('extensions'):
                packages.append(extension.join(['', self.phpversion]))
        return packages

class FPM54(Interpretor):
    def __init__(self, configuration, application):
        super(FPM54, self).__init__(configuration, application)

    def pre_install(self):
        os.system('apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2098A6E')
        os.system('echo deb http://packages.dotdeb.org stable all | tee /etc/apt/sources.list.d/php54.list')
        os.system('apt-get update')
        self.phpversion = subprocess.check_output('apt-cache madison php5|grep 5.4|awk \'{print "="$3}\'', shell=True)

    def get_packages(self):
        packages = ['php5-cli', 'php5-common'.join(['', self.phpversion]), 'php5-fpm'.join(['', self.phpversion])]
        return packages



    def post_install(self):
        # Remove autostart
        os.system('service php5-fpm stop')

class FPM55(Interpretor):
    def __init__(self, configuration, application):
        self.phpversion = ''
        super(FPM55, self).__init__(configuration, application)

    def pre_install(self):
        os.system('apt-get update')

    def get_packages(self):
        packages = ['php5-cli', 'php5-fpm']
        return packages

    def post_install(self):
        # Remove autostart
        os.system('service php5-fpm stop')

class HHVM(Interpretor):
    def __init__(self, configuration, application):
        self.phpversion = ''
        super(HHVM, self).__init__(configuration, application)

    def configure(self, frontend):
        # If frontend supports unix sockets, use them by default
        self.socket_address = 'unix:/var/run/hhvm/sock'
        if not frontend.supports_unix_proxy():
            self.socket_address = '127.0.0.1:9000'

        # Clear pre-configured pools
        map(os.unlink, [os.path.join('/etc/hhvm', f) for f in os.listdir('/etc/hhvm')])
        templates_mapping = {
            'php.ini': '/etc/hhvm/php.ini',
            'server.ini': '/etc/hhvm/server.ini'
        }

        for template, target in templates_mapping.iteritems():
            shutil.copyfile(
                os.path.join(self.application.get('source_directory'), 'php', 'interpretor', 'hhvm', template),
                target
            )

        # Replace pool listen address
        listen_address = 'hhvm.server.port = 9000'
        if self.socket_address[0:5] == 'unix:':
            listen_address = 'hhvm.server.file_socket = ' + self.socket_address[5:]

        replace(templates_mapping['server.ini'], '_FPM_POOL_LISTEN_', listen_address)

        if 'ini_file' in self.configuration:
            shutil.copyfile(
                os.path.join(self.application.get('directory'), self.configuration.get('ini_file')),
                '/etc/hhvm/php.ini'
            )

        # Clean and touch some files
        for file_path in ['/var/log/hhvm/error.log']:
            open(file_path, 'a').close()
            os.system('chown %s %s' % (self.application.get('user'), file_path))

        # Clean run directory
        run_directory = '/var/run/hhvm'
        if not os.path.exists(run_directory):
            os.makedirs(run_directory)

        # Fix user rights
        os.system('chown -R %s /etc/hhvm /var/run/hhvm' % self.application.get('user'))

    def pre_install(self):
        # Add GPG key and source list
        os.system('curl -L http://dl.hhvm.com/conf/hhvm.gpg.key | apt-key add -')
        os.system('echo deb http://dl.hhvm.com/ubuntu trusty main | tee /etc/apt/sources.list.d/hhvm.list')
        os.system('apt-get update')

    def get_packages(self):
        return ['hhvm']

    def get_packages_extensions(self):
        return []

    def post_install(self):
        # Set up HHVM fastcgi and remove autostart
        os.system('/usr/share/hhvm/install_fastcgi.sh')
        os.system('service hhvm stop')

    def setup_environment(self):
        pass

    def get_startup_cmd(self):
        return '/usr/bin/hhvm --config /etc/hhvm/php.ini --config /etc/hhvm/server.ini --user %s --mode daemon -vPidFile=/var/run/hhvm/pid' % self.application.get('user')

interpretors = {
    'fpm54': FPM54,
    'fpm55': FPM55,
    'hhvm': HHVM
}
