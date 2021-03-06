#!/bin/bash
set -e

TAG2=$(grep -e 'mumuki/mumuki-python2-worker:[0-9]*\.[0-9]*' ./lib/python2_runner.rb -o | tail -n 1)
TAG3=$(grep -e 'mumuki/mumuki-python3-worker:[0-9]*\.[0-9]*' ./lib/python3_runner.rb -o | tail -n 1)

echo "Pulling $TAG2..."
docker pull $TAG2

echo "Pulling $TAG3..."
docker pull $TAG3
