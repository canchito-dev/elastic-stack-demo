#!/bin/bash

function check_docker() {
  if ! docker ps -q &>/dev/null; then
    echo "This example requires Docker but it doesn't appear to be running.  Please start Docker and try again."
    exit 1
  fi

  return 0
}

function check_elasticsearch_up() {
  FOUND=$(curl -s -f http://localhost:9200/_cluster/health | grep '"status":"green"')
  # True of the length if "STRING" is zero.
  if [ -z "$FOUND" ]; then
    return 1
  fi
  return 0
}

function check_service_up() {
  url=$1

  FOUND=$(curl --write-out 'HTTP %{http_code}' --fail --silent --output /dev/null $url)
  # True if the strings are equal. "=" may be used instead of "==" for strict POSIX compliance.
  if [ "HTTP 200" == "$FOUND" ]; then
    return 0
  fi
  return 1
}

function check_packetbeat_up() {
  url=$1

  FOUND=$(docker exec -it $(docker container ls | grep packetbeat-demo | awk '{print $1}') curl --write-out 'HTTP %{http_code}' --fail --silent --output /dev/null $url)
  # True if the strings are equal. "=" may be used instead of "==" for strict POSIX compliance.
  if [ "HTTP 200" == "$FOUND" ]; then
    return 0
  fi
  return 1
}

function retry() {
    local -r -i max_wait="$1"; shift
    local -r cmd="$@"

    local -i sleep_interval=5
    local -i curr_wait=0

    until $cmd
    do
        if (( curr_wait >= max_wait ))
        then
            echo "ERROR: Failed after $curr_wait seconds. Please troubleshoot and run again."
            return 1
        else
            printf "."
            curr_wait=$((curr_wait+sleep_interval))
            sleep $sleep_interval
        fi
    done
    printf "\n"
}

echo 'Making sure Docker is up and running'
check_docker

echo "Cleaning up first!"
./stop-all-single-node.sh

MAX_WAIT=120
ELASTICSEARCH_URL=http://localhost:9200/_cluster/health?pretty
KIBANA_URL=http://localhost:5601/api/status
FILEBEAT_TO_ELASTICSEARCH_URL=http://localhost:5166/?pretty
LOGSTASH_URL=http://localhost:9600/?pretty
FILEBEAT_TO_LOGSTASH_URL=http://localhost:5266/?pretty
METRICBEAT_URL=http://localhost:5366/?pretty
HEARTBEAT_URL=http://localhost:5466/?pretty
PACKETBEAT_URL=http://localhost:5066/?pretty

echo "Starting Kibana and Elasticsearch"
docker-compose -f docker-compose-elk-single-node.yml up -d --build

# Verify Elasticsearch service has started
echo "Waiting up to $MAX_WAIT seconds for Elasticsearch to start"
retry $MAX_WAIT check_elasticsearch_up || exit 1
sleep 2 # give Elasticsearch an extra moment to fully mature
curl -s -f $ELASTICSEARCH_URL
echo "Elasticsearch has started!"

# Verify Kibana service has started
echo "Waiting up to $MAX_WAIT seconds for Kibana to start"
retry $MAX_WAIT check_service_up $KIBANA_URL || exit 1
sleep 3 # give Kibana an extra moment to fully mature
curl -s -f $KIBANA_URL
echo "Kibana has started!"

echo "Starting Filebeat that sends logs directly to Elasticsearch"
docker-compose -f docker-compose-filebeat-to-elasticseach.yml up -d --build

# Verify Filebeat to Elasticsearch service has started
echo "Waiting up to $MAX_WAIT seconds for Filebeat to Elasticsearch to start"
retry $MAX_WAIT check_service_up $FILEBEAT_TO_ELASTICSEARCH_URL || exit 1
sleep 2 # give Filebeat to Elasticsearch an extra moment to fully mature
curl -s -f $FILEBEAT_TO_ELASTICSEARCH_URL
echo "Filebeat to Elasticsearch has started!"

echo "Starting Logstash"
docker-compose -f docker-compose-logstash.yml up -d --build

# Verify Logstash service has started
echo "Waiting up to $MAX_WAIT seconds for Logstash to start"
retry $MAX_WAIT check_service_up $LOGSTASH_URL || exit 1
sleep 2 # give Logstash an extra moment to fully mature
curl -s -f $LOGSTASH_URL
echo "Logstash has started!"

echo "Starting Filebeat that sends logs to Logstash"
docker-compose -f docker-compose-filebeat-to-logstash.yml up -d --build

# Verify Filebeat to Logstash service has started
echo "Waiting up to $MAX_WAIT seconds for Filebeat to Logstash to start"
retry $MAX_WAIT check_service_up $FILEBEAT_TO_LOGSTASH_URL || exit 1
sleep 2 # give Filebeat to Logstash an extra moment to fully mature
curl -s -f $FILEBEAT_TO_LOGSTASH_URL
echo "Filebeat to Logstash has started!"

echo "Starting Metricbeat"
docker-compose -f docker-compose-metricbeat.yml up -d --build

# Verify Metricbeat service has started
echo "Waiting up to $MAX_WAIT seconds for Metricbeat to start"
retry $MAX_WAIT check_service_up $METRICBEAT_URL || exit 1
sleep 2 # give Metricbeat an extra moment to fully mature
curl -s -f $METRICBEAT_URL
echo "Metricbeat has started!"

echo "Starting Heartbeat"
docker-compose -f docker-compose-heartbeat.yml up -d --build

# Verify Heartbeat service has started
echo "Waiting up to $MAX_WAIT seconds for Heartbeat to start"
retry $MAX_WAIT check_service_up $HEARTBEAT_URL || exit 1
sleep 2 # give Heartbeat an extra moment to fully mature
curl -s -f $HEARTBEAT_URL
echo "Heartbeat has started!"

echo "Changing to heartbeat directory"
cd ./heartbeat
echo "Importing Heartbeat dashboard!"
curl -XPOST http://localhost:5601/api/saved_objects/_import?createNewCopies=true -H "kbn-xsrf: true" --form file=@http_dashboard.ndjson

echo "Changing to parent directory"
cd ../

echo "Starting Packetbeat"
docker-compose -f docker-compose-packetbeat.yml up -d --build

# Verify Packetbeat service has started
echo "Waiting up to $MAX_WAIT seconds for Packetbeat to start"
retry $MAX_WAIT check_packetbeat_up $PACKETBEAT_URL || exit 1
sleep 2 # give Packetbeat an extra moment to fully mature
curl -s -f $PACKETBEAT_URL
echo "Packetbeat has started!"