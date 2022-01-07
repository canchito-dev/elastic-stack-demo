ARG ELK_VERSION
FROM docker.elastic.co/beats/heartbeat:${ELK_VERSION}

# add custom configuration
COPY --chown=root:heartbeat heartbeat.yml /usr/share/heartbeat/heartbeat.yml