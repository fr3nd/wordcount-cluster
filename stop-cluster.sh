#! /bin/sh
#
# stop-cluster.sh
# Copyright (C) 2016 Carles Amigó <fr3nd@fr3nd.net>
#
# Distributed under terms of the MIT license.
#

. ./config

echo "*** Removing Swarm manager..."
docker-machine rm -f manager
for n in $(seq $WORKERS)
do
  echo "*** Removing Swarm worker${n}..."
  docker-machine rm -f worker${n}
done
