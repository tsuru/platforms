# Copyright 2025 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:24.04
COPY . /var/lib/tsuru/java
RUN set -ex \
    && sudo /var/lib/tsuru/java/install \
    && sudo rm -rf /var/lib/tsuru/java/install /var/lib/apt/lists/* \
    && sudo ln -sf /var/lib/tsuru/base/deploy /var/lib/tsuru/deploy
