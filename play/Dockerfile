# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform:18.04
ADD	. /var/lib/tsuru/play
RUN	sudo cp /var/lib/tsuru/play/deploy /var/lib/tsuru
RUN	sudo chmod -R 777 /var/lib/tsuru/play
RUN set -ex; \
    sudo /var/lib/tsuru/play/install; \
    sudo rm -rf /var/lib/apt/lists/*
