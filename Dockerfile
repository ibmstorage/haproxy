FROM registry.access.redhat.com/ubi9-minimal:latest

RUN microdnf update -y

# If you edit this version number, edit it here *and* the LABEL below:
RUN microdnf install -y haproxy && rpm -q haproxy-2.8.14

# Creating haproxy user and group
RUN microdnf install -y shadow-utils
RUN groupadd haproxygroup
RUN useradd -g haproxygroup haproxyuser

# Only install qatengine package when building on x86_64 arch.
RUN if [ $(uname --hardware-platform) == "linux/amd64" ]; then microdnf install -y qatengine; fi

LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL com.redhat.component="rhceph-haproxy-container"
LABEL name=rhceph/rhceph-haproxy-rhel9
LABEL version="2.8.14"
LABEL description="HAProxy container"
LABEL summary="Provides HAproxy container."
LABEL io.k8s.display-name="HAProxy container"
LABEL io.k8s.description="HAProxy container"
LABEL io.openshift.tags="2.8.14"
LABEL cpe=cpe:/a:redhat:ceph_storage:9.0::el9

STOPSIGNAL SIGUSR1

RUN mkdir /licenses
COPY ./licenses /licenses

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

USER haproxyuser

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
