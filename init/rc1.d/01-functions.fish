#!/usr/bin/fish

function kafka
  if test 0 -eq (count $argv)
    kafka_help
    return
  end
  switch $argv[1]

    case topics
        kafka_topics 

    case topic
        kafka_topic $argv[2] $argv[3] $argv[4]

    case help
        kafka_help
    case '*'
      kafka_help
  end
end

function kafka_help -d "display usage info"
  
  echo "vSPARC:"
  echo ""
  echo ""

  echo "USAGE:"
  echo ""
  echo "kafka <command> [options] [args]"
  echo ""
  
  echo "kafka topic name replication_factor partitions"
  echo "  create a new topic"
  echo ""

  echo "kafka topics"
  echo "  get a list of the topics in the kafka broker"
  echo ""

  echo "kafka help"
  echo "  this..."
  echo ""

end

function kafka_topics
  set pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_ZK_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_ip (ssh $KAFKA_JUMP_HOST kubectl get pod $zk_pod_name -n  $KAFKA_K8S_NS -o json | jq -r '.status.podIP');
  set cmd "\"unset JMX_PORT && kafka-topics.sh --zookeeper $zk_pod_ip:2181 --list\"";
  ssh $KAFKA_JUMP_HOST kubectl -n $KAFKA_K8S_NS exec $pod_name -c kafka -- /bin/bash -c $cmd
end

function kafka_topic -a topic_name replication_factor partitions
  set pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_ZK_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_ip (ssh $KAFKA_JUMP_HOST kubectl get pod $zk_pod_name -n  $KAFKA_K8S_NS -o json | jq -r '.status.podIP');
  set cmd "\"unset JMX_PORT && kafka-topics.sh --create --zookeeper $zk_pod_ip:2181 --replication-factor $replication_factor --partitions $partitions --topic $topic_name\"";
  ssh $KAFKA_JUMP_HOST kubectl -n $KAFKA_K8S_NS exec $pod_name -c kafka -- /bin/bash -c $cmd
end

