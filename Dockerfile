FROM linuxserver/transmission:latest

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="antartica"

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	wireguard-tools \
	ip6tables


# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091
VOLUME /config /downloads /watch
