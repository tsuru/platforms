# -*- coding: utf-8 -*-

# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

import os
import shutil
from utils import replace
from vars import php_versions, default_version

class Frontend(object):
    def __init__(self, configuration, application):
        self.configuration = configuration
        self.application = application

    def pre_install(self):
        pass

    def post_install(self):
        pass

    def supports_unix_proxy(self):
        return True

    def setup_environment(self):
        pass

class Apache(Frontend):
    def supports_unix_proxy(self):
        return False

    def post_install(self):
        os.system('service apache2 stop')
        os.system('update-rc.d apache2 remove')

    def configure(self, interpretor=None):
        # Set apache virtual host
        vhost_directory = '/etc/apache2/sites-enabled'
        confs_directory = '/etc/apache2/conf-available'
        map(os.unlink, [os.path.join(vhost_directory, f) for f in os.listdir(vhost_directory)])
        vhost_path = os.path.join(vhost_directory, 'tsuru-vhost.conf')
        security_dst_file = os.path.join(confs_directory, 'security.conf')
        shutil.copyfile(self.get_vhost_filepath(), vhost_path)
        security_src_file = os.path.join(self.application.get('source_directory'), 'php', 'frontend',
                                         'apache', 'security.conf')
        shutil.copyfile(security_src_file, security_dst_file)

        # Set interpretor address is there's any
        if interpretor is not None:
            address = interpretor.get_address()
            replace(vhost_path, 'FASTCGI_INTERPRETOR_ADDRESS', address)
            os.system('a2enmod proxy_fcgi')

        # Empty `ports.conf` file
        open('/etc/apache2/ports.conf', 'w').close()

        # Set Apache environment variables accessible when running though cmd
        with open('/etc/profile', 'a') as profile_file:
            profile_file.write(
                "\n"
                "export APACHE_RUN_USER=%s\n"
                "export APACHE_RUN_GROUP=%s\n"
                "export APACHE_PID_FILE=/var/run/apache2/apache2.pid\n"
                "export APACHE_RUN_DIR=/var/run/apache2\n"
                "export APACHE_LOCK_DIR=/var/lock/apache2\n"
                "export APACHE_LOG_DIR=/var/log/apache2\n"
                "sudo chmod 777 /dev/stdout /dev/stderr\n"
                 % (self.application.get('user'), self.application.get('user'))
            )

        # Create directories
        logs_directory = '/var/log/apache2'
        directories = [logs_directory, '/var/lock/apache2', '/var/run/apache2']
        for directory in directories:
            if not os.path.exists(directory):
                os.makedirs(directory)

        map(os.unlink, [os.path.join(logs_directory, f) for f in os.listdir(logs_directory)])
        for log_file in ['access.log', 'error.log']:
            log_file_path = os.path.join(logs_directory, log_file)
            open(log_file_path, 'a').close()

        # Configure modules if needed
        for module in self.configuration.get('modules', []):
            os.system('a2enmod %s' % module)

        # Fix user rights
        os.system('chown -R %s /etc/apache2 /var/run/apache2 /var/log/apache2 /var/lock/apache2' % self.application.get('user'))

    def get_vhost_filepath(self):
        if 'vhost_file' in self.configuration:
            return os.path.join(self.application.get('directory'), self.configuration.get('vhost_file'))
        return self.get_default_vhost_filepath()

    def get_default_vhost_filepath(self):
        return os.path.join(self.application.get('source_directory'), 'php', 'frontend', 'apache', 'vhost.conf')

    def get_startup_cmd(self):
        return '/usr/sbin/apache2 -d /etc/apache2 -k start'


class ApacheModPHP(Apache):
    def get_default_vhost_filepath(self):
        return os.path.join(self.application.get('source_directory'), 'php', 'frontend', 'apache-mod-php', 'vhost.conf')

    def configure(self, interpretor=None):
        super(ApacheModPHP, self).configure(interpretor)
        php_version = str(self.configuration.get('version', default_version))
        if php_version not in php_versions:
            php_version = default_version
        for version in php_versions:
            os.system('sudo /usr/sbin/a2dismod php{}'.format(version))
        os.system('sudo /usr/sbin/a2enmod php{}'.format(php_version))

    def get_startup_cmd(self):
            return '/usr/sbin/apache2 -d /etc/apache2 -k start -DNO_DETACH'


class Nginx(Frontend):
    def post_install(self):
        os.system('service nginx stop')
        os.system('update-rc.d nginx remove')

    def configure(self, interpretor=None):
        # Copy nginx configuration
        nginx_config_file = os.path.join(self.application.get('source_directory'), 'php', 'frontend', 'nginx', 'nginx.conf')
        shutil.copyfile(nginx_config_file, '/etc/nginx/nginx.conf')

        # Copy vhost configuration
        shutil.copyfile(self.get_vhost_filepath(), '/etc/nginx/vhost.conf')
        if interpretor is not None:
            address = interpretor.get_address()
            replace('/etc/nginx/vhost.conf', 'FASTCGI_INTERPRETOR_ADDRESS', address)

        # Clean log files
        logs_directory = '/var/log/nginx'
        if not os.path.exists(logs_directory):
            os.makedirs(logs_directory)

        map(os.unlink, [os.path.join(logs_directory, f) for f in os.listdir(logs_directory)])
        for log_file in ['access.log', 'error.log']:
            log_file_path = os.path.join(logs_directory, log_file)
            open(log_file_path, 'a').close()

        # Fix user rights
        open('/run/nginx.pid', 'a').close()
        os.system('chown -R %s /etc/nginx /var/log/nginx /var/lib/nginx /run/nginx.pid' % self.application.get('user'))

    def get_vhost_filepath(self):
        if 'vhost_file' in self.configuration:
            return os.path.join(self.application.get('directory'), self.configuration.get('vhost_file'))

        return os.path.join(self.application.get('source_directory'), 'php', 'frontend', 'nginx', 'vhost.conf')

    def get_startup_cmd(self):
        return '/usr/sbin/nginx'

frontends = {
    'apache-mod-php': ApacheModPHP,
    'apache': Apache,
    'nginx': Nginx
}
