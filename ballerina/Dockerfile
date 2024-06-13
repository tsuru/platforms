# Copyright 2019 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:24.04
COPY . /var/lib/tsuru/ballerina
RUN set -ex \
    && sudo cp /var/lib/tsuru/ballerina/deploy /var/lib/tsuru \
    && sudo /var/lib/tsuru/ballerina/install \
    && sudo rm -rf /var/lib/apt/lists/*
