#!/bin/bash

# set number of containers
NUM_CONTAINERS=20

echo "Start running vkernel-runtime containers."

# build containers
for i in $(seq 1 $NUM_CONTAINERS); do
  docker run --rm --runtime=vkernel-runtime -itd --name ubuntu_container_$i ubuntu /bin/bash
done

echo "Created $NUM_CONTAINERS containers."
