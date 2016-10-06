# Ruby platform

The Ruby platform uses ruby 2.2.3 by default and get your dependencies from
``Gemfile``.

You can define what ruby version you want to with two ways:

    * set ruby version in ``Gemfile``:
        $ cat Gemfile
        ...
        ruby 2.2
        ...

    * ``.ruby-version`` file:
        $ cat .ruby-version
        2.2

## Configure custom ruby repository

The platform downloads ruby from a remote uri and you can define an environment variable `RUBY_REPO` to customize where from it will be downloaded. The platform will download ruby from: `$RUBY_REPO/ruby-$RUBY_VERSION.tgz`, where `RUBY_VERSION` is the ruby version figured out by the last step.

## Configure custom Gem source

You can configure a custom source to be used for your gems using the environment variable `GEM_SOURCE`, this will be passed to the `gem install --source` argument.
