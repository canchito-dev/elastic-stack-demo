ARG ELK_VERSION
FROM docker.elastic.co/beats/metricbeat:${ELK_VERSION}

# add custom configuration
COPY --chown=root:metricbeat metricbeat.yml /usr/share/metricbeat/metricbeat.yml