# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:22.04
COPY . /var/lib/tsuru/lua
RUN set -ex \
    && sudo /var/lib/tsuru/lua/install \
    && sudo rm -rf /var/lib/tsuru/lua/install /var/lib/apt/lists/* \
    && sudo ln -sf /var/lib/tsuru/lua/deploy /var/lib/tsuru/deploy
