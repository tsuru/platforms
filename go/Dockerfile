# Copyright 2017 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform
ADD	. /var/lib/tsuru/go
RUN	cp /var/lib/tsuru/go/deploy /var/lib/tsuru
RUN set -ex; \
    apt-get update && \
    apt-get install -y bzr mercurial git && \
    /var/lib/tsuru/go/install && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean
