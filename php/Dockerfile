# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM    tsuru/base-platform
RUN     echo 'deb http://archive.ubuntu.com/ubuntu/ vivid main restricted universe multiverse' >> /etc/apt/sources.list
RUN     echo 'deb http://archive.ubuntu.com/ubuntu/ vivid-security main restricted universe multiverse' >> /etc/apt/sources.list
RUN     echo 'APT::Default-Release "trusty";' >> /etc/apt/apt.conf.d/01ubuntu
ADD	. /var/lib/tsuru/php
RUN	cp /var/lib/tsuru/php/deploy /var/lib/tsuru
RUN	cp /var/lib/tsuru/php/interpretor/fpm5/php5_apt_preferences /etc/apt/preferences.d/php5
RUN	/var/lib/tsuru/php/install
