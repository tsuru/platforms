platforms
=========

[![Build Status](https://travis-ci.org/tsuru/platforms.png?branch=master)](https://travis-ci.org/tsuru/platforms)

Source for official Docker images of tsuru platforms.

All platforms are available in Docker Hub:

* tsuru/buildpack: https://hub.docker.com/r/tsuru/buildpack/
* tsuru/cordova: https://hub.docker.com/r/tsuru/cordova/
* tsuru/elixir: https://hub.docker.com/r/tsuru/elixir/
* tsuru/go: https://hub.docker.com/r/tsuru/go/
* tsuru/java: https://hub.docker.com/r/tsuru/java/
* tsuru/nodejs: https://hub.docker.com/r/tsuru/nodejs/
* tsuru/php: https://hub.docker.com/r/tsuru/php/
* tsuru/play: https://hub.docker.com/r/tsuru/play/
* tsuru/python: https://hub.docker.com/r/tsuru/python/
* tsuru/python3: https://hub.docker.com/r/tsuru/python3/
* tsuru/pypy: https://hub.docker.com/r/tsuru/pypy/
* tsuru/ruby: https://hub.docker.com/r/tsuru/ruby/
* tsuru/static: https://hub.docker.com/r/tsuru/static/

Installing platforms
--------------------

In order to use one of the platforms provided here, you need to have
tsuru-admin installed and run ``tsuru-admin platform-add``:

```bash
% tsuru-admin platform-add <platform-name>
```

Prior to version 0.13.0, tsurud didn't accept prebuilt images in
platform-add/platform-update, so in order to add a platform from this
repository, you need to create a Dockerfile with a single line (``FROM
<image-name>``).

Dockerfiles are provided in the basebuilder repository, so in order to add a
platform, it's as simple as running ``tsuru-admin platform-add``. For example,
for the Java platform:

```bash
% tsuru-admin platform-add java -d https://raw.github.com/tsuru/basebuilder/master/java/Dockerfile
```

Replace "java" with any other platform and you're good to go!

Creating new platforms
----------------------

tsuru requires only a single executable for platforms:
``/var/lib/tsuru/deploy``. It also expects the
[deploy-agent](http://github.com/tsuru/deploy-agent) to be installed. This
script will receive two parameters: the deployment type (which is always
"archive" in latest release) and the URL for the archive.

We provide a base image which platform developers can use to build upon:
[base-platform](https://github.com/tsuru/base-platform). This platform provides
a base deployment script, which handles package downloading and extraction in
proper path, along with operating system package management. For more details,
check the README of base-platform.
