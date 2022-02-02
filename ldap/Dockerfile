FROM alpine:3.11.3

ENV VERSION "2.4.48"
ENV LOG_LEVEL "stats"

ENV ORGANISATION_NAME "Contrast Security"
ENV SUFFIX "dc=example,dc=com"
ENV ROOT_USER "admin"
ENV ROOT_PW "nimda"
ENV ACCESS_CONTROL "access to * by * read"

RUN apk add --update openldap openldap-back-mdb && \
    mkdir -p /run/openldap /var/lib/openldap/openldap-data && \
    rm -rf /var/cache/apk/*

COPY scripts/* /etc/openldap/
COPY entrypoint.sh /

EXPOSE 389
EXPOSE 636

VOLUME [/var/lib/openldap/openldap-data]

ENTRYPOINT ["/entrypoint.sh"]