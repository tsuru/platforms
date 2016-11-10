# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM    tsuru/base-platform
RUN	echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu trusty main' >> /etc/apt/sources.list
ADD	. /var/lib/tsuru/php
RUN	cp /var/lib/tsuru/php/deploy /var/lib/tsuru
RUN	cp /var/lib/tsuru/php/interpretor/fpm5/php5_apt_preferences /etc/apt/preferences.d/php5
RUN	/var/lib/tsuru/php/install
