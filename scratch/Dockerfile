# Copyright 2020 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:22.04
COPY . /var/lib/tsuru/scratch
RUN set -ex \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo cp /var/lib/tsuru/scratch/deploy /var/lib/tsuru
