# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:24.04
COPY . /var/lib/tsuru/static
RUN set -ex \
    && sudo /var/lib/tsuru/static/install \
    && sudo rm -rf /var/lib/tsuru/static/install /var/lib/apt/lists/* \
    && sudo cp /var/lib/tsuru/static/deploy /var/lib/tsuru
