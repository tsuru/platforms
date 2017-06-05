# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform
ADD . /var/lib/tsuru/python
RUN cp /var/lib/tsuru/python/deploy /var/lib/tsuru
RUN apt-get update && \
    apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev git && \
    /var/lib/tsuru/python/install && \
    apt-get remove --purge -y libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
    tk-dev git && \
    apt-get install -y libssl1.0.0 zlib1g libbz2-1.0 \
    libreadline6 libsqlite3-0 libncurses5 libncursesw5 && \
    apt-get autoremove -y
