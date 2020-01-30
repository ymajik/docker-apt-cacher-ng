ARG vcs_ref
ARG build_date
ARG version="0.0.1"

FROM debian:buster-slim

LABEL org.label-schema.name = "ymajik/docker-apt-cacher-ng" \
      org.label-schema.description = "Deploy apt-cacher-ng for caching apt repos" \
      org.label-schema.vendor="ymajik" \
      org.label-schema.docker.cmd="docker run --name apt-cacher-ng -d --restart=always --publish 3142:3142 --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng ymajik/apt-cacher-ng" \
      org.label-schema.url="https://github.com/ymajik/docker-apt-cacher-ng" \
      org.label-schema.vcs-url="https://github.com/ymajik/docker-apt-cacher-ng.git" \
      org.label-schema.schema-version="1.0"

ENV APT_CACHER_NG_VERSION="3.2-2" \
    APT_CACHER_NG_CACHE_DIR="/var/cache/apt-cacher-ng" \
    APT_CACHER_NG_LOG_DIR="/var/log/apt-cacher-ng" \
    APT_CACHER_NG_USER="apt-cacher-ng"

RUN apt-get update &&\
       DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
       apt-cacher-ng=${APT_CACHER_NG_VERSION}* ca-certificates wget curl &&\
       sed 's/# ForeGround: 0/ForeGround: 1/' -i /etc/apt-cacher-ng/acng.conf &&\
       sed 's/# PassThroughPattern:.*this would allow.*/PassThroughPattern: .* #/' -i /etc/apt-cacher-ng/acng.conf &&\
       rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3142/tcp

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
   CMD wget -q0 - http://localhost:3142/acng-report.html || exit 1

VOLUME ["${APT_CACHER_NG_CACHE_DIR}"]

ENTRYPOINT ["/sbin/entrypoint.sh"]

LABEL org.label-schema.version="$version" \
      org.label-schema.vcs-ref="$vcs_ref" \
      org.label-schema.build-date="$build_date"

CMD ["/usr/sbin/apt-cacher-ng"]
