# -*- coding: utf-8 -*-

# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

import os
import shutil
import subprocess
from .utils import replace
from .vars import php_versions

class Interpretor(object):
    def __init__(self, configuration, application):
        self.configuration = configuration
        self.application = application
        self.socket_address = None

    def configure(self, frontend):
        # If frontend supports unix sockets, use them by default
        self.socket_address = 'unix:/var/run/php/fpm.sock'
        if not frontend.supports_unix_proxy():
            self.socket_address = '127.0.0.1:9000'

        # Clear pre-configured pools
        for version in php_versions:
            removed_fpm_files = []
            for f in os.listdir('/etc/php/{}/fpm/pool.d'.format(version)):
                removed_fpm_files.append(os.path.join('/etc/php/{}/fpm/pool.d'.format(version), f))
            list(map(os.unlink, removed_fpm_files))
            templates_mapping = {
                'pool.conf': '/etc/php/{}/fpm/pool.d/tsuru.conf',
                'php-fpm.conf': '/etc/php/{}/fpm/php-fpm.conf'
            }

            for template, target in templates_mapping.items():
                shutil.copyfile(
                    os.path.join(self.application.get('source_directory'), 'php', 'interpretor', 'fpm',
                                 template.format(version)),
                    target.format(version)
                )

            # Replace pool listen address
            listen_address = self.socket_address
            if listen_address[0:5] == 'unix:':
                listen_address = listen_address[5:]

            replace(templates_mapping['pool.conf'].format(version), '_FPM_POOL_LISTEN_', listen_address)
            replace(templates_mapping['php-fpm.conf'].format(version), '_PHP_VERSION_', version)

            # Fix user rights
            run_directory = '/var/run/php'
            if not os.path.exists(run_directory):
                os.makedirs(run_directory)
            os.system('chown -R {} /etc/php/{}/fpm /var/run/php'.format(self.application.get('user'), version))

            # Clean and touch some files
            for file_path in ['/var/log/php-fpm.log', '/etc/php/{}/fpm/environment.conf'.format(version)]:
                open(file_path, 'a').close()
                os.system('chown %s %s' % (self.application.get('user'), file_path))

            if 'ini_file' in self.configuration:
                shutil.copyfile(
                    os.path.join(self.application.get('directory'), self.configuration.get('ini_file')),
                    '/etc/php/{}/fpm/php.ini'.format(version)
                )

    def get_address(self):
        return self.socket_address

    def setup_environment(self):
        target = '/etc/php/{}/fpm/environment.conf'
        for version in php_versions:
            with open(target.format(version), 'w') as f:
                for (k, v) in list(self.application.get('env', {}).items()):
                    if v:
                        f.write('env[%s] = %s\n' % (k, v))

    def get_startup_cmd(self, version):
        return '/usr/sbin/php-fpm{0} --fpm-config /etc/php/{0}/fpm/php-fpm.conf'.format(version)

    def get_packages_extensions(self):
        packages = []
        if 'extensions' in self.configuration:
            for extension in self.configuration.get('extensions'):
                packages.append(extension.join(['', self.phpversion]))
        return packages

    def pre_install(self):
        pass

class FPM(Interpretor):
    def __init__(self, configuration, application):
        self.phpversion = ''
        super(FPM, self).__init__(configuration, application)

    def post_install(self):
        # Remove autostart
        for version in php_versions:
            os.system('service php{}-fpm stop'.format(version))

interpretors = {
    'fpm': FPM,
    'fpm54': FPM,
    'fpm55': FPM,
}
