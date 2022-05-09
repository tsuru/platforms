# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:20.04
COPY ./install /var/lib/tsuru/python/
RUN set -ex; \
    sudo /var/lib/tsuru/python/install; \
    sudo rm -rf /var/lib/apt/lists/*
COPY ./deploy /var/lib/tsuru/python/
RUN sudo cp /var/lib/tsuru/python/deploy /var/lib/tsuru
ENV PYENV_ROOT="/var/lib/pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
