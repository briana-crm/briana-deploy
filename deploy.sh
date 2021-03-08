#!/usr/bin/env bash

IFS=',' read -ra workers <<< "${WORKERS:-""}"

#initialize docker swarm cluster as a manager node
docker swarm init
join_token=$(docker swarm join-token -q worker)

worker_node_number=1
#iterate over worker hosts
for worker in "${workers[@]}"; do
  worker_node_name=briana-worker-node-$worker_node_number
  #create generic docker machines
  docker-machine create \
  --driver generic \
  --generic-ip-address="$worker" \
  --generic-ssh-key ~/.ssh/id_rsa \
  $worker_node_name

  worker_node_number=$(expr $worker_node_number + 1)

  #join worker node to cluster
  docker-machine ssh worker_node_name \
  && docker swarm join --token "$join_token" \
  && exit
done

#deploy stack into swarm cluster
docker stack deploy --compose-file docker-compose.yml briana
