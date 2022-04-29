# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform:22.04
ADD	. /var/lib/tsuru/static
RUN	sudo cp /var/lib/tsuru/static/deploy /var/lib/tsuru
RUN set -ex; \
    sudo /var/lib/tsuru/static/install; \
    sudo rm -rf /var/lib/apt/lists/*
