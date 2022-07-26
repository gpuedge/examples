#!/bin/bash
set -e -o pipefail

echo "GPUX-blender-v0.0.1"

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

ISZIPPED=$(file -i source | grep zip)
if [ -z "$ISZIPPED" ]
then
  unzip source
  BLEND=$(ls | grep .blend | head -1)
  mv $BLEND source.blend
else
  mv source source.blend
fi

echo "downloading script.py"
aria2c -x5 https://raw.githubusercontent.com/gpuedge/examples/main/blender/script.py

echo "running blender $3"
blender -b --factory-startup -P script.py -- $3 || true
echo "blender finished"

FILE='file=@out.zip'
FILEGPUX='@out.zip'
FILEEXT='.zip'
zip out.zip out_*.png

if [ "$2" == "SIASKY" ]
then
  echo "uploading to SIASKY"
  curl -s -X POST https://siasky.net/skynet/skyfile -F $FILE | jq -r '.skylink' | awk '{print "https://siasky.net/"$1}'
elif [ "$2" == "IPFS" ]
then
  echo "uploading to IPFS"
  curl -s --unix-socket /api -X POST http://dontcare/api/v0/add -F $FILE | jq -r '.Hash' | awk '{print "https://cloudflare-ipfs.com/ipfs/"$1}'
elif [ "$2" == "GPUX" ]
then
  echo "uploading to GPUX"
  curl -s --unix-socket /api -H "Content-Type:application/octet-stream" -X POST --data-binary $FILEGPUX "http://dontcare/api/file/upload" | jq -r '.sha1' | awk -v filext="$FILEEXT" '{print $1filext}'
else
  echo "uploading to URL $2"
  curl -s -X POST "$2" -F $FILE
fi
