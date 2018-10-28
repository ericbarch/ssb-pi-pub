# ssb-pi-pub
# Run a Scuttlebutt pub on a Raspberry Pi via Docker

# debian w/ ARM qemu
FROM arm32v7/debian:9

# blame the human that created this
LABEL maintainer="ericb@ericbarch.com"

# define versions of what we'll install
ENV NVM_VERSION 0.33.11
ENV NODE_VERSION 8

# upgrade everything, install nodejs deps
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get dist-upgrade -y \
    && apt-get install -y build-essential python-dev curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# create user for running sbot
RUN useradd -ms /bin/bash sbot

# run all following commands under the sbot user
USER sbot
WORKDIR /home/sbot

# install nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash

# install node (via nvm)
RUN /bin/bash -c "source /home/sbot/.nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default"

# install sbot
RUN /bin/bash -c "source /home/sbot/.nvm/nvm.sh && npm install -g scuttlebot-release"

# publish sbot public port
EXPOSE 8008
EXPOSE 8008/udp

# enable healthcheck for sbot
HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=10 \
  CMD /bin/bash -c "source /home/sbot/.nvm/nvm.sh && sbot whoami || exit 1"

# copy launch script into image
ADD sbot.sh /sbot.sh

# create dir for ssb data, set proper permissions
RUN mkdir ~/.ssb && chown -R sbot: ~/.ssb

# launch sbot on container start and allow overriding of sbot command
ENTRYPOINT [ "/sbot.sh" ]
CMD [ "server" ]
