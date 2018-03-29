# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform
ADD	. /var/lib/tsuru/elixir
RUN	sudo cp /var/lib/tsuru/elixir/deploy /var/lib/tsuru
RUN set -ex; \
    sudo /var/lib/tsuru/elixir/install; \
    sudo rm -rf /var/lib/apt/lists/*
RUN	yes | mix local.rebar --force
RUN	yes | mix local.hex --force