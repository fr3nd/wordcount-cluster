#! /bin/sh
#
# init.sh
# Copyright (C) 2016 Carles Amigó <fr3nd@fr3nd.net>
#
# Distributed under terms of the MIT license.
#

set -e

. ./config

which docker-machine > /dev/null || (echo "docker-machine is needed to continue. Please install it..."; exit 1)

echo "*** Creating Swarm manager..."
docker-machine create -d $DOCKER_MACHINE_DRIVER manager
echo "*** Configuring Swarm manager..."
eval $(docker-machine env manager)
docker run -d -p 3376:3376 -t -v /var/lib/boot2docker:/certs:ro swarm manage -H 0.0.0.0:3376 --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/server.pem --tlskey=/certs/server-key.pem token://${SWARM_TOKEN}

for n in $(seq $WORKERS)
do
  echo "*** Creating Swarm worker${n}..."
  docker-machine create -d $DOCKER_MACHINE_DRIVER worker${n}
  echo "*** Configuring Swarm worker${n}..."
  eval $(docker-machine env worker${n})
  docker run -d swarm join --addr=$(docker-machine ip worker${n}):2376 token://${SWARM_TOKEN}
done

eval $(docker-machine env manager)
export DOCKER_HOST=$(docker-machine ip manager):3376

docker pull fr3nd/wordcount:latest
