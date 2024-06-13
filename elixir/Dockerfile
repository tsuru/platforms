# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:24.04
COPY . /var/lib/tsuru/elixir
RUN set -ex \
    && sudo /var/lib/tsuru/elixir/install \
    && sudo rm -rf /var/lib/apt/lists/* \
    && yes | mix local.rebar --force \
    && yes | mix local.hex --force \
    && sudo ln -sf /var/lib/tsuru/elixir/deploy /var/lib/tsuru/deploy
