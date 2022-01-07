ARG ELK_VERSION
FROM docker.elastic.co/beats/packetbeat:${ELK_VERSION}

# add custom configuration
COPY --chown=root:packetbeat packetbeat.yml /usr/share/packetbeat/packetbeat.yml