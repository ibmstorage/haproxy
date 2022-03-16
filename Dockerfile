FROM registry.access.redhat.com/ubi8/ubi-minimal AS builder

RUN microdnf update -y

RUN microdnf install gcc glibc-devel \
    lua-libs make openssl openssl-devel \
    pcre-devel tar zlib-devel gzip redhat-rpm-config diffutils

ADD scratch.repo /etc/yum/repos.d/scratch.repo

RUN microdnf install -y haproxy22

FROM --copy=builder registry.access.redhat.com/ubi8/ubi-minimal

LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL com.redhat.component="haproxy-container"
LABEL name="haproxy"
LABEL version="2.2.19"
LABEL description="HAProxy container"
LABEL summary="Provides HAproxy container."
LABEL io.k8s.display-name="HAProxy container"
LABEL io.k8s.description="HAProxy container"

STOPSIGNAL SIGUSR1

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
