FROM registry.access.redhat.com/ubi8/ubi-minimal AS builder

RUN microdnf install gcc glibc-devel && \
lua-libs make openssl openssl-devel && \
pcre-devel tar zlib-devel gzip redhat-rpm-config diffutils && \
&& mkdir /usr/src/haproxy && cd /usr/src/haproxy && \
curl -s -o-  https://www.haproxy.org/download/2.3/src/haproxy-2.3.17.tar.gz | tar --strip-components=1 -C /usr/src/haproxy -zxf  -

RUN make -j16 CPU=generic TARGET=linux-glibc USE_OPENSSL=1 USE_PCRE=1 USE_ZLIB=1 USE_CRYPT_H=1 USE_LINUX_TPROXY=1 USE_GETADDRINFO=1 USE_REGPARM=1 EXTRA_OBJS="contrib/prometheus-exporter/service-prometheus.o" 'ADDINC=-O2 -g -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fexceptions -fstack-protector-strong -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -m64 -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection' 'ADDLIB=-Wl,-z,relro  -Wl,-z,now -specs=/usr/lib/rpm/redhat/redhat-hardened-ld'

FROM --copy=builder registry.access.redhat.com/ubi8/ubi-minimal

LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL com.redhat.component="haproxy-container"
LABEL name="haproxy"
LABEL version="2.3.17"
LABEL description="HAProxy container"
LABEL summary="Provides HAproxy container."
LABEL io.k8s.display-name="HAProxy container"
LABEL io.k8s.description="HAProxy container"

STOPSIGNAL SIGUSR1

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
