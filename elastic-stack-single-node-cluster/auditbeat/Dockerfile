ARG ELK_VERSION
FROM docker.elastic.co/beats/auditbeat:${ELK_VERSION}

# add custom configuration
COPY --chown=root:auditbeat auditbeat.yml /usr/share/auditbeat/auditbeat.yml