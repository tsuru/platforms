# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform
ADD	. /var/lib/tsuru/play
RUN	cp /var/lib/tsuru/play/deploy /var/lib/tsuru
RUN	chmod -R 777 /var/lib/tsuru/play
RUN set -ex; \
    /var/lib/tsuru/play/install; \
    rm -rf /var/lib/apt/lists/*
