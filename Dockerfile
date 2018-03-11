FROM zimme/mono

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="zimme version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="zimme"

# environment settings
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
	echo "**** install radarr ****" && \
	radarr_tag=$(curl -sX GET "https://api.github.com/repos/Radarr/Radarr/releases" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
	mkdir -p \
	/opt/radarr && \
	curl -o \
	/tmp/radar.tar.gz -L \
	"https://github.com/galli-leo/Radarr/releases/download/${radarr_tag}/Radarr.develop.${radarr_tag#v}.linux.tar.gz" && \
	tar ixzf \
	/tmp/radar.tar.gz -C \
	/opt/radarr --strip-components=1 && \
	echo "**** clean up ****" && \
	rm -rf \
	/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 7878
VOLUME /config /downloads /movies

# Add libs & tools
RUN apt-get update && \
	apt-get install -y --no-install-recommends libfuse-dev autoconf automake wget build-essential git  && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Install rar2fs
COPY rar2fs-assets/install_rar2fs.sh /tmp/
RUN /bin/sh /tmp/install_rar2fs.sh


# CLEAN Image
RUN apt-get remove -y autoconf build-essential git automake && \
	apt autoremove -y
RUN rm -rf /tmp/* /var/tmp/*

# Add start script
COPY rar2fs-assets/30-rar2fs-mount /etc/cont-init.d/
