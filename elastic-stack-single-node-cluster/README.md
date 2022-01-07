# Elastic Stack Single Node Cluster

*NOTE*: Starting from Heartbeat 7.0, Elastic team decided to remove Heartbeat dashboard from 7.0 [#10294](https://github.com/elastic/beats/pull/10294)
In case you would like to import it manually you can find the dashboard here [Uptime Contrib Repository](https://github.com/elastic/uptime-contrib)

## How to start
1) Change to ```elastic-stack-single-node-cluster``` directory.
2) Execute the script ```./start-all-single-node.sh```

The script will start all the services in the following order:
1) Elasticsearch and Kibana
2) Filebeat to Elasticsearch
3) Logstash
4) Filebeat to Logstash
5) Metricbeat
6) Heartbeat
7) Packetbeat

Before moving on the starting the next service, it makes sure that the previous one is up and running.

Once Heartbeat is up and running, it will import its dashboard. With it, you should not need to manually imported.

Wait a file, and go to [Kibana > Management > Stack Monitoring](http://localhost:5601/app/monitoring), and select 
```elastic-stack-single-node-cluster```. You should see all the services up and running.

> _NOTE:_ By default, Docker networking will connect the Packetbeat container to an isolated virtual network, with a 
> limited view of network traffic. We use _docker-compose_'s option <code>network_mode: host</code>, because we wish to 
> connect the container directly to the host network in order to see traffic destined for, and originating from, the host 
> system.
> 
> So for our use case, we have the packetbeat container running with host networking and not attach it to the docker networks.
> Because of that, we are no longer able to connect it to the elasticsearch instance via http://elasticsearch-demo:9200, 
> so replaced this config value to http://localhost:9200. All this is done in _packetbeat.yml_.
> 
> In addition, the validation to see if the service is up has to be done a bit different.

![Elastic Stack Monitoring in Kibana](../images/stack_monitoring_in_kibana.png)

## Clean up and Prune
1) Change to ```elastic-stack-single-node-cluster``` directory.
2) Execute the script ```./stop-all-single-node.sh```