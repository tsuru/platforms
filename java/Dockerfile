# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform
ADD	. /var/lib/tsuru/java
RUN	cp /var/lib/tsuru/base/deploy /var/lib/tsuru
RUN	/var/lib/tsuru/java/install
