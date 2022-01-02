ARG ELK_VERSION
FROM docker.elastic.co/beats/filebeat:${ELK_VERSION}

ARG FILEBEAT_CONFIG

# add custom configuration
COPY --chown=root:filebeat ${FILEBEAT_CONFIG}.yml /usr/share/filebeat/filebeat.yml