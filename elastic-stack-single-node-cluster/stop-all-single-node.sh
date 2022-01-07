#!/bin/bash

docker-compose \
  -f docker-compose-packetbeat.yml \
  -f docker-compose-heartbeat.yml \
  -f docker-compose-metricbeat.yml \
  -f docker-compose-filebeat-to-logstash.yml \
  -f docker-compose-logstash.yml \
  -f docker-compose-filebeat-to-elasticseach.yml \
  -f docker-compose-elk-single-node.yml \
  down -v