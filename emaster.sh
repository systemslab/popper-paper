#!/bin/bash

set -e
set -x

docker run --rm -it \
  --name="emaster" \
  --net=host \
  -v `pwd`:/experiments \
  -v ~/.ssh:/root/.ssh \
  --workdir=/experiments \
  michaelsevilla/emaster
