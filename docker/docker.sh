#!/bin/bash
set -e

cd "$(dirname $0)"

declare -ar images=('debian-wheezy'
                    'debian-jessie'
                    'debian-stretch'
                    'ubuntu-trusty'
                    'ubuntu-xenial')

declare -r node_dl='./node.tar.xz'
declare -r node_out='./node'
declare -i push=0

while [ -n "$1" ]; do
  if [ -z "$1" ]; then break; fi
  param="$1"
  value="$2"
  case $param in
    --push)
      push=1
      shift
    ;;
    *)
      echo "Unknown arg: $param"
      exit 1
    ;;
  esac
done

set -u

if [ ! -f "$node_dl" ]; then
  curl 'https://nodejs.org/dist/v6.10.1/node-v6.10.1-linux-x64.tar.xz' >> "$node_dl"
fi

if [ ! -d  "$node_out" ]; then
  tar -xJf "$node_dl"
  mv 'node-v6.10.1-linux-x64' node
fi

for image in ${images[@]}; do
  docker build -t heartsucker/node-deb-test:$image -f $image .
done

if [[ "$push" -eq 1 ]]; then
  for image in ${images[@]}; do
    docker push heartsucker/node-deb-test:$image
  done
fi
