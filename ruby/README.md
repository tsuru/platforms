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
