#!/usr/bin/env fish

# Environment variables (Universal):
# 1. KAFKA_JUMP_HOST - Host node running kubernetes master in control of inst of kafka we care about
# 2. KAFKA_K8S_NS    - what k8s namespace the kafka is running in.
# 3. KAFKA_K8S_NAME  - the base name used in k8s for the kafka pods
# 4. KAFKA_K8S_ZK_NAME - the base name of the zookeeper pods

if not set -q KAFKA_JUMP_HOST then
  set -U KAFKA_JUMP_HOST dev-k8s-1
end

if not set -q KAFKA_K8S_NS then
  set -U KAFKA_K8S_NS dev-tlive-es
end

if not set -q KAFKA_K8S_NAME then
  set -U KAFKA_K8S_NAME kafka
end

if not set -q KAFKA_K8S_ZK_NAME then
  set -U KAFKA_K8S_ZK_NAME es-zk
end

