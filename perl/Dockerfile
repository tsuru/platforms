# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:22.04
COPY . /var/lib/tsuru/perl
RUN set -ex \
    && sudo /var/lib/tsuru/perl/install \
    && sudo rm -rf /var/lib/tsuru/perl/install /var/lib/apt/lists/* \
    && sudo cp /var/lib/tsuru/perl/deploy /var/lib/tsuru
