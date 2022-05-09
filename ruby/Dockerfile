# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM tsuru/base-platform:20.04
COPY . /var/lib/tsuru/ruby
RUN set -ex \
    && sudo /var/lib/tsuru/ruby/install \
    && sudo rm -rf /var/lib/tsuru/ruby/install /var/lib/apt/lists/* \
    && sudo cp /var/lib/tsuru/ruby/deploy /var/lib/tsuru
ENV GEM_PATH=/home/application/ruby \
    GEM_HOME=/home/application/ruby \
    BUNDLE_APP_CONFIG=/home/application/ruby/.bundle/config
