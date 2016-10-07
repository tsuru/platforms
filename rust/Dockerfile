# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	tsuru/base-platform
RUN	pwd
RUN	ls
RUN	ls .
ADD	. /var/lib/tsuru/rust
RUN	cp /var/lib/tsuru/rust/deploy /var/lib/tsuru
RUN	/var/lib/tsuru/rust/install
