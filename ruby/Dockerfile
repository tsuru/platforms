# Copyright 2015 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform
ADD	. /var/lib/tsuru/ruby
RUN	cp /var/lib/tsuru/ruby/deploy /var/lib/tsuru
RUN	/var/lib/tsuru/ruby/install
RUN	echo "source /home/application/ruby.sh" >> /etc/profile
