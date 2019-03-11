#!/usr/bin/fish

function kafka
  if test 0 -eq (count $argv)
    kafka_help
    return
  end

  switch $argv[1]
    case size
      kafka_size $argv[2]

    case topics
      kafka_topics 

    case totaloffsets
      kafka_total_offsets  $argv[2] 

    case offsets
      kafka_offsets $argv[2] 

    case groups
      kafka_groups 

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

  echo "kafka groups"
  echo "  get all of the consumer groups"
  echo ""

  echo "kafka offsets <topic>"
  echo "  get all of the offsets for a topic"
  echo ""

  echo "kafka totaloffsets <topic>"
  echo "  total offsets for a topic"
  echo ""

  echo "kafka size <group>"
  echo "  Get the size of the offsets for consumer group supplied"
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

function kafka_size -a group
  set pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_ZK_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_ip (ssh $KAFKA_JUMP_HOST kubectl get pod $zk_pod_name -n  $KAFKA_K8S_NS -o json | jq -r '.status.podIP');
  # set cmd "\"unset JMX_PORT && kafka-consumer-groups.sh  --zookeeper $zk_pod_ip:2181 --describe --group $group\""
  set cmd "\"unset JMX_PORT && kafka-consumer-groups.sh  --bootstrap-server 127.0.0.1:9092 --describe --group $group\""
  ssh $KAFKA_JUMP_HOST kubectl -n $KAFKA_K8S_NS exec $pod_name -c kafka -- /bin/bash -c $cmd 
end

function kafka_groups
  set pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_ZK_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_ip (ssh $KAFKA_JUMP_HOST kubectl get pod $zk_pod_name -n  $KAFKA_K8S_NS -o json | jq -r '.status.podIP');
  set cmd "\"unset JMX_PORT && kafka-consumer-groups.sh  --bootstrap-server 127.0.0.1:9092 --list\""
  ssh $KAFKA_JUMP_HOST kubectl -n $KAFKA_K8S_NS exec $pod_name -c kafka -- /bin/bash -c $cmd 
end

function kafka_offsets -a topic
  set pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_name (ssh $KAFKA_JUMP_HOST kubectl get pods -n $KAFKA_K8S_NS | grep $KAFKA_K8S_ZK_NAME | cut -d' ' -f 1|head -n 1);
  set zk_pod_ip (ssh $KAFKA_JUMP_HOST kubectl get pod $zk_pod_name -n  $KAFKA_K8S_NS -o json | jq -r '.status.podIP');
  set cmd "\"unset JMX_PORT && kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic $topic --time -1\""
  # set cmd "\"unset JMX_PORT && kafka-consumer-groups.sh  --bootstrap-server 127.0.0.1:9092 --list\""
  ssh $KAFKA_JUMP_HOST kubectl -n $KAFKA_K8S_NS exec $pod_name -c kafka -- /bin/bash -c $cmd 
end

function kafka_total_offsets -a topic
  kafka offsets $topic | cut -d':' -f 3 | awk '{total = total + $1}END{print total}'
end
