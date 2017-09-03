FROM debian:stretch-slim

LABEL maintainer=ymajik@gmail.com
    #   org.label-schema.name = "ymajik/docker-apt-cacher-ng" \
    #   org.label-schema.description = "Deploy apt-cacher-ng for caching apt repos" \
    #   org.label-schema.version="1.2.0" \
    #   org.label-schema.vendor="ymajik" \
    #   org.label-schema.docker.cmd="docker run --name apt-cacher-ng -d --restart=always --publish 3142:3142 --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng ymajik/apt-cacher-ng" \
    #   org.label-schema.url="https://github.com/ymajik/docker-apt-cacher-ng" \
    #   org.label-schema.vcs-url="https://github.com/ymajik/docker-apt-cacher-ng.git" \
    #   org.label-schema.schema-version="1.0"

ENV APT_CACHER_NG_VERSION=2-2 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-cacher-ng="${APT_CACHER_NG_VERSION}*" \
 && sed 's/# ForeGround: 0/ForeGround: 1/' -i /etc/apt-cacher-ng/acng.conf \
 && sed 's/# PassThroughPattern:.*this would allow.*/PassThroughPattern: .* #/' -i /etc/apt-cacher-ng/acng.conf \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3142
VOLUME ["${APT_CACHER_NG_CACHE_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/apt-cacher-ng"]
