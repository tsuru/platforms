# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform:22.04
ADD	. /var/lib/tsuru/ruby
RUN	sudo cp /var/lib/tsuru/ruby/deploy /var/lib/tsuru
RUN set -ex; \
    sudo /var/lib/tsuru/ruby/install; \
    sudo rm -rf /var/lib/apt/lists/*
ENV GEM_PATH=/home/application/ruby \
    GEM_HOME=/home/application/ruby \
    BUNDLE_APP_CONFIG=/home/application/ruby/.bundle/config
