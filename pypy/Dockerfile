# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform
ADD	. /var/lib/tsuru/pypy
RUN	cp /var/lib/tsuru/pypy/deploy /var/lib/tsuru
RUN set -ex; \
    /var/lib/tsuru/pypy/install; \
    rm -rf /var/lib/apt/lists/*
