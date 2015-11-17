# PHP platform

The PHP platform is built to be able to manage multiple front-end and interpretors. You can manage them in your `tsuru.yml` configuration file.

```yml
php:
    frontend:
        name: nginx
    interpretor:
        name: fpm54
    composer: true
```

## Front ends

The following frontends are currently supported:
- `apache`: Apache
- `nginx`: Nginx

You can chose between them by setting the `php.frontend.name` parameter:
```yml
php:
    frontend:
        name: apache
```

Each frontend supports options that can be set in the `php.frontend.options` parameters.

All these options are not required, and can be used the following way:
```yml
php:
    frontend:
        name: apache
        options:
            vhost_file: /path/to/vhost.conf
            modules:
                - rewrite
```

### Apache options

- `vhost_file`: The relative path of your Apache virtual host configuration file
- `modules`: An array of module names, such as `rewrite` for instance

### Nginx options

- `vhost_file`: The relative path of your Nginx virtual host configuration file

## Interpretors

The following PHP interpretors are supported:

- `fpm54`: PHP 5.4 though PHP-FPM
- `fpm55`: PHP 5.5 though PHP-FPM
- `hhvm`: HipHop Virtual Machine (PHP 5.4)

You can chose between them by setting the `php.interpretor.name` parameter:
```yml
php:
    interpretor:
        name: fpm54
```

These interpretors can also have options configured in the `php.interpretor.options` parameter.

If you choose `fpm54` interpretor, use `extensions` option to install php5 extensions instead of using `requirements.apt`

All these options are not required and can be used the following ways
```yml
php:
    interpretor:
        name: fpm54
        options:
            ini_file: /path/to/file.ini
            extensions:
                - php5-mysql
```

## `fpm54` options

- `ini_file`: The relative path of your `php.ini` file in your project, that will replace the default one
- `extensions`: A list of php5 extensions you need

## `fpm55` options

- `ini_file`: The relative path of your `php.ini` file in your project, that will replace the default one
- `extensions`: A list of php5 extensions you need

## `hhvm` options

- `ini_file`: The relative path of your `php.ini` file in your project, that will replace the default one

## General options

In addition to the `frontend` and `interpretor` options, there's an other one:

- `composer`: A boolean that is by default to true. If the value is true, it'll run a `composer install` if there's a `composer.json` file at the root of your application.

## Backward compatibility

To keep the backward compatibility, there's also a `apache-mod-php` frontend that is in fact the Apache with modphp enabled, that remove the need of an interpretor.
That's currently the default configuration if no parameter is set.

## Next steps

With the current implementation, it's quite easy to add another interpretor for instance.
