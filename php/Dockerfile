# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:20.04
COPY . /var/lib/tsuru/php
RUN set -ex \
    && sudo /var/lib/tsuru/php/install \
    && sudo rm -rf /var/lib/tsuru/php/install /var/lib/apt/lists/* \
    && sudo cp /var/lib/tsuru/php/deploy /var/lib/tsuru
