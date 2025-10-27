FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

ARG BUILD_DATE
ARG VERSION
LABEL build_version="[Mollomm1 Mod] Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="mollomm1"

ARG DEBIAN_FRONTEND="noninteractive"

COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap
COPY options.json /
COPY /root/ /

# Install core tools + Flatpak dependencies
RUN echo "**** installing base packages ****" && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        firefox jq wget flatpak dbus-x11 bubblewrap mesa-utils libglu1-mesa && \
    chmod +x /install-de.sh && /install-de.sh && \
    chmod +x /installapps.sh && /installapps.sh && rm /installapps.sh

# Setup Flatpak
RUN mkdir -p /run/dbus /var/lib/flatpak /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    dbus-uuidgen > /etc/machine-id && \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
    echo "XDG_DATA_DIRS=/usr/share:/usr/local/share:/var/lib/flatpak/exports/share:/config/.local/share/flatpak/exports/share" >> /etc/environment

# Allow D-Bus and Flatpak to start in user sessions
RUN ln -sf /bin/true /usr/bin/systemctl

# GPU and sound support (optional)
ENV DISPLAY=:0
ENV PULSE_SERVER=unix:/run/pulse/native
RUN usermod -aG video,render abc || true

# Cleanup
RUN apt-get autoclean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 3000
VOLUME /config
CMD ["/bin/bash"]
