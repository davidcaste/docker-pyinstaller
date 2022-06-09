ARG BASE_TAG=3.10-slim-buster

FROM python:${BASE_TAG}

ADD install-rust.sh /install-rust.sh

RUN apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      binutils \
      curl \
      g++ \
      gcc \
      make \
      musl \
      musl-dev \
      musl-tools && \
    pip install -U pip setuptools wheel && \
    pip install patchelf-wrapper pyinstaller SCons && \
    BOOTLOADER_CC=/usr/bin/musl-gcc pip install https://github.com/JonathonReinhart/staticx/archive/master.zip && \
    if [ "$(dpkg --print-architecture)" = "armhf" ]; then \
      echo "Instructing pip to fetch wheels from piwheels.org" >&2; \
      printf "[global]\nextra-index-url=https://www.piwheels.org/simple\n" > /etc/pip.conf; \
    fi; \
    /install-rust.sh && \
    rm -f /install-rust.sh && \
    apt-get remove --purge -yq \
      curl \
      g++ \
      gcc \
      make \
      musl \
      musl-dev \
      musl-tools && \
    apt-get autoremove --purge -yq && \
    rm -rf /root/.cache /root/.rustup /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD entrypoint.sh /entrypoint.sh

ENV DEPS= HIDDEN_IMPORTS= REQUIREMENTS_FILE=requirements.txt \
    SKIP_PIP_INSTALL_PROJECT= UPDATE_PIP= DIST_PATH= CLEAN= \
    OWNER=1000:1000 \
    STATICX= STATICX_ARGS= STATIX_TARGET= STATICX_OUTPUT=

VOLUME ["/app"]

ENTRYPOINT ["/entrypoint.sh"]

# vim set ft=dockerfile et ts=2 sw=2 :
