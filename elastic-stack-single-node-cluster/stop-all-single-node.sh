#!/bin/bash

docker-compose \
  -f docker-compose-filebeat-to-logstash.yml \
  -f docker-compose-logstash.yml \
  -f docker-compose-filebeat-to-elasticseach.yml \
  -f docker-compose-es-single-node.yml \
  down -v