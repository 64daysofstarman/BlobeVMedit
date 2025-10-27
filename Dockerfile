FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="[Mollomm1 Mod] Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="mollomm1"

ARG DEBIAN_FRONTEND="noninteractive"

# prevent Ubuntu's firefox stub from being installed
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap
COPY options.json /
COPY /root/ /

# Install basic packages + Flatpak + D-Bus + Bubblewrap
RUN echo "**** install packages ****" && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        firefox jq wget \
        flatpak dbus-x11 bubblewrap && \
    chmod +x /install-de.sh && \
    /install-de.sh

# Install additional apps
RUN chmod +x /installapps.sh && /installapps.sh && rm /installapps.sh

# Setup Flathub remote
RUN mkdir -p /run/dbus && \
    dbus-daemon --system & \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Cleanup to reduce image size
RUN echo "**** cleanup ****" && \
    apt-get autoclean && \
    rm -rf \
      /config/.cache \
      /var/lib/apt/lists/* \
      /var/tmp/* \
      /tmp/*

# ports and volumes
EXPOSE 3000
VOLUME /config

# Default command: bash shell
CMD ["/bin/bash"]
