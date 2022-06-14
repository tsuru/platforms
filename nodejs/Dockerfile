# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:20.04
COPY . /var/lib/tsuru/nodejs
RUN set -ex \
    && /var/lib/tsuru/nodejs/install \
    && sudo rm -rf /var/lib/tsuru/nodejs/install /var/lib/apt/lists/* \
    && sudo ln -sf /var/lib/tsuru/nodejs/deploy /var/lib/tsuru/deploy
