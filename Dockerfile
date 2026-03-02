FROM registry.redhat.io/ubi8/ubi-minimal:latest

RUN microdnf update -y

# If you edit this version number, edit it here *and* the LABEL below:
RUN microdnf install -y haproxy22

# Creating haproxy user and group
RUN microdnf install -y shadow-utils
RUN groupadd haproxygroup 
RUN useradd -g haproxygroup haproxyuser

LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL com.redhat.component="rhceph-haproxy-container"
LABEL name=rhceph/rhceph-haproxy-rhel8
LABEL version=2.2.19
LABEL description="HAProxy container"
LABEL summary="Provides HAproxy container."
LABEL io.k8s.display-name="HAProxy container"
LABEL io.k8s.description="HAProxy container"
LABEL io.openshift.tags="2.2.19"
LABEL cpe=cpe:/a:redhat:ceph_storage:5.3::el8

STOPSIGNAL SIGUSR1

RUN mkdir /licenses
COPY ./licenses /licenses

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

USER haproxyuser

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
