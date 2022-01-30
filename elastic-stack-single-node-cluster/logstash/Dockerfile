ARG ELK_VERSION

FROM docker.elastic.co/logstash/logstash:${ELK_VERSION}

RUN rm -f /usr/share/logstash/pipeline/logstash.conf

# pipeline source folder
ADD --chown=logstash:logstash pipeline/ /usr/share/logstash/pipeline/

# pipeline configurations
ADD --chown=root:logstash config/pipelines.yml /usr/share/logstash/config/pipelines.yml

# add logstash configuration
ADD --chown=root:logstash config/logstash.yml /usr/share/logstash/config/logstash.yml

# add any plug in
# RUN bin/logstash-plugin install logstash-filter-math