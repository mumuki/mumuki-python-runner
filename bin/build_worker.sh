#!/bin/bash
set -e

TAG2=$(grep -e 'mumuki/mumuki-python2-worker:[0-9]*\.[0-9]*' ./lib/python2_runner.rb -o | tail -n 1)
TAG3=$(grep -e 'mumuki/mumuki-python3-worker:[0-9]*\.[0-9]*' ./lib/python3_runner.rb -o | tail -n 1)

cp worker/rununittest worker2/rununittest
cp worker/rununittest worker3/rununittest

echo "Building $TAG2..."
pushd worker2
docker build . -t $TAG2
popd

echo "Building $TAG3..."
pushd worker3
docker build . -t $TAG3
