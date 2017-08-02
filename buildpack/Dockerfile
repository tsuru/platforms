# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

FROM	progrium/buildstep
RUN	locale-gen en_US.UTF-8
ENV	LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive
RUN	mkdir -p /var/lib/tsuru/base
ADD	. /var/lib/tsuru/buildpack
RUN	cp /var/lib/tsuru/buildpack/deploy /var/lib/tsuru
RUN apt-get update && apt-get install -y --no-install-recommends \
            curl \
            sudo \
    && rm -rf /var/lib/apt/lists/*
RUN curl -sLo base-platform.tar.gz https://github.com/tsuru/base-platform/tarball/master; \
    tar -xvf base-platform.tar.gz -C /var/lib/tsuru/base --strip 1; \
    rm -rf base-platform.tar.gz
RUN set -ex; \
    sudo /var/lib/tsuru/buildpack/install; \
    sudo rm -rf /var/lib/apt/lists/*
USER ubuntu
