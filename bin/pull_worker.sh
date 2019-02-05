#!/bin/bash

TAG=$(grep -e 'mumuki/mumuki-python-worker:[0-9]*\.[0-9]*' ./lib/python_runner.rb -o | tail -n 1)

echo "Pulling $TAG..."
docker pull $TAG
