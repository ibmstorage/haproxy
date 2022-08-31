FROM registry.redhat.io/ubi9/ubi-minimal:latest

RUN microdnf update -y

# If you edit this version number, edit it here *and* the LABEL below:
RUN microdnf install -y haproxy && rpm -q haproxy-2.4.17

LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL com.redhat.component="rhceph-haproxy-container"
LABEL name="haproxy"
LABEL version=2.4.17
LABEL description="HAProxy container"
LABEL summary="Provides HAproxy container."
LABEL io.k8s.display-name="HAProxy container"
LABEL io.k8s.description="HAProxy container"

STOPSIGNAL SIGUSR1

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]

