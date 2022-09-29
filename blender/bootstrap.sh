#!/bin/bash
set -e -o pipefail

echo "GPUX-blender-v0.0.2"

# Fix for NVIDIA CUDA key rotation: https://github.com/nytimes/rd-blender-docker/issues/41
echo "temp fix cuda key rotation.. https://github.com/nytimes/rd-blender-docker/issues/41"
rm /etc/apt/sources.list.d/cuda.list \
  && rm /etc/apt/sources.list.d/nvidia-ml.list \
  && apt-key del 7fa2af80 \
  && apt-get update \
  && apt-get install -y --no-install-recommends curl \
  && curl -sSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb \
  && dpkg -i cuda-keyring_1.0-1_all.deb \
  && rm cuda-keyring_1.0-1_all.deb \
  && rm -rf /var/lib/apt/lists/*

echo "downloading extra packages.."
apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install curl jq zip file aria2 > /dev/null

echo "downloading .blend source from $1"
if [[ "$1" =~ ^ipfs.* ]]
then
  IPFSURL=$1
  CID="${IPFSURL:7}"
  curl --unix-socket /api -X POST "http://dontcare/api/v0/cat?arg=$CID" --output source
elif [[ "$1" =~ ^gpux.* ]]
then
  GPUXURL=$1
  CID="${GPUXURL:7}"
  curl --unix-socket /api "http://dontcare/api/file/download/$CID" --output source
else
  aria2c -x5 --check-certificate=false "$1" -o source
fi

echo "checking if zipped.."
ISZIPPED=$(file -i source | grep "application/zip" || true)
# in bash 0 is true 1 is false, so turn 1 into 0 by !
if ! [ -z "${ISZIPPED}" ]
then
  echo "unzipping.."
  unzip source
  BLEND=$(ls | grep .blend | head -1)
  mv $BLEND source.blend
else
  echo "not zipped"
  mv source source.blend
fi

echo "downloading script.py"
aria2c -x5 https://raw.githubusercontent.com/gpuedge/examples/main/blender/script.py

echo "running blender $3"
blender -b --factory-startup -P script.py -- $3 || true
echo "blender finished"