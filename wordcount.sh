#! /bin/sh
#
# wordcount.sh
# Copyright (C) 2016 Carles Amigó <fr3nd@fr3nd.net>
#
# Distributed under terms of the MIT license.
#

set -e

. ./config

which docker-machine > /dev/null || (echo "docker-machine is needed to continue. Please install it..."; exit 1)
which parallel > /dev/null || (echo "GNU parallel is needed to continue. Please install it..."; exit 1)

eval $(docker-machine env manager)
export DOCKER_HOST=$(docker-machine ip manager):3376

TEMPDIR=$(mktemp --directory)
split -l $SPLIT_LINES - $TEMPDIR/wordcount-
find $TEMPDIR -type f \
  | parallel -j$MAX_MAP_PROCS --no-notice "cat {} | docker run --rm -i fr3nd/wordcount map.py" \
  | sort \
  | docker run --rm -i fr3nd/wordcount reduce.py \
  | sort -n -k2 -r
rm -rf $TEMPDIR
