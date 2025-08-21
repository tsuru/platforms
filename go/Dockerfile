# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:22.04
COPY . /var/lib/tsuru/go
RUN set -ex \
  && sudo /var/lib/tsuru/go/install \
  && sudo rm -rf /var/lib/tsuru/go/install /var/lib/apt/lists/* \
  && sudo ln -sf /var/lib/tsuru/go/deploy /var/lib/tsuru/deploy
