#/bin/bash
REV=$1

echo "[Escualo::PythonServer] Fetching GIT revision"
echo -n $REV > version

echo "[Escualo::PythonServer] Pulling docker image"
docker pull mumuki/mumuki-python-worker