#!/bin/bash

set -e
set -x

DIR=`pwd`
ROOTDIR=`dirname $DIR`

docker run --rm -it \
  --name="emaster" \
  --net=host \
  -v $ROOTDIR:/experiments \
  -v ~/.ssh:/root/.ssh \
  --workdir=/experiments \
  michaelsevilla/emaster
