#! /bin/sh
#
# wordcount.sh
# Copyright (C) 2016 Carles Amigó <fr3nd@fr3nd.net>
#
# Distributed under terms of the MIT license.
#

. ./config

eval $(docker-machine env manager)
export DOCKER_HOST=$(docker-machine ip manager):3376

TEMPDIR=$(mktemp --directory)
split -l $SPLIT_LINES - $TEMPDIR/wordcount-
find $TEMPDIR -type f \
  | xargs -I {} --max-procs=$MAX_MAP_PROCS -n 1 sh -c "cat {} | docker run --rm -i fr3nd/wordcount map.py" \
  | sort \
  | docker run --rm -i fr3nd/wordcount reduce.py \
  | sort -n -k2 -r
rm -rf $TEMPDIR
