# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform
ADD . /var/lib/tsuru/go
RUN sudo cp /var/lib/tsuru/go/deploy /var/lib/tsuru
RUN set -ex; \
    sudo /var/lib/tsuru/go/install; \
    sudo rm -rf /var/lib/apt/lists/*
