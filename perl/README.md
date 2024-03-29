# Perl platform

The Perl platform supports Perl 5.18.2 (on Ubuntu 14.04 LTS) or Perl 5.22.1 (on Ubuntu 16.04 LTS).

## Code deployment

If you just run a ``tsuru app deploy`` of your code, tsuru will try
to download all of your depencies using ``cpanfile`` or ``cpanfile.snapshot``.

## Code deployment with dependencies

There are two ways to list the applications dependencies: ``cpanfile`` or ``cpanfile.snapshot``.
The priority order is: ``cpanfile.snapshot`` -> ``cpanfile``. The file should be in the root of deploy files.

### Using [carton](https://metacpan.org/pod/Carton) + [cpanfile](https://metacpan.org/pod/cpanfile)

You can define a file called ``cpanfile`` that list all CPAN dependencies of your application,
each line represents one dependency, here's an example:

	$ cat cpanfile
	requires 'Mojolicious';


### Using [carton](https://metacpan.org/pod/Carton) + cpanfile.snapshot

After invokin ``tsuru app deploy``, tsuru will receive your code and tell the platform
to install all the depencies using ``carton install --cached --deployment``.

