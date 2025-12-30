# Copyright 2025 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# syntax=docker/dockerfile:1

# Stage 1: Get base-platform from official tsuru image
ARG BASE_PLATFORM_VERSION=24.04
FROM tsuru/base-platform:${BASE_PLATFORM_VERSION} AS base-platform

# Stage 2: Build main image
# Migration from deprecated progrium/buildstep to maintained gliderlabs/herokuish
FROM gliderlabs/herokuish:latest-24

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive

# Create required directories
RUN mkdir -p /var/lib/tsuru/base

# Add buildpack files
ADD . /var/lib/tsuru/buildpack
RUN cp /var/lib/tsuru/buildpack/deploy /var/lib/tsuru

# Install dependencies with optimized layer caching
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Copy base-platform files from stage 1 instead of downloading tarball
COPY --from=base-platform /var/lib/tsuru/base /var/lib/tsuru/base

# Update base-platform config to use heroku user instead of ubuntu
RUN sed -i 's/USER=ubuntu/USER=heroku/g' /var/lib/tsuru/base/rc/config && \
    sed -i 's|HOME=/home/ubuntu|HOME=/home/heroku|g' /var/lib/tsuru/base/rc/config

# Run installation and cleanup in single layer
RUN set -ex; \
    /var/lib/tsuru/buildpack/install; \
    rm -rf /var/lib/apt/lists/*

# Set proper permissions for app directory and test directories
# /home/application needs group write permissions for tests
RUN mkdir -p /app/.profile.d && chown -R heroku:heroku /app && \
    mkdir -p /home/application/current && chown -R heroku:heroku /home/application && \
    chmod -R g+w /home/application

# Add heroku user to sudo group without password
RUN echo "heroku ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/heroku && \
    chmod 0440 /etc/sudoers.d/heroku