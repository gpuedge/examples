# Blender

## How to use

Start Command
```
source_url - URL to download your .blend file from (gpux://{sha1} for using the node itself, ipfs://{cid} for IPFS)
upload_target - GPUX | SIASKY | IPFS | URL to upload to
core - OPTIX | CUDA
width - X
height - Y
cycles - Cycles to do

./bootstrap.sh <source_url> <upload_target> <core> <width> <height> <cycles> <isAnimation>
./bootstrap.sh gpux://4FWrow8vhpCVnY8B1DGZNyx4SF6U GPUX OPTIX 1080 1350 1024
./bootstrap.sh gpux://4FWrow8vhpCVnY8B1DGZNyx4SF6U GPUX OPTIX 1080 1350 1024 ANI
```

Storage supported
```
# Native
GPUX Job Storage (https://node.com/api/job/storage/download/job_uuid)

# Decentralized
IPFS
SIASKY https://siasky.net/ (simple but flakey, not recommmended)

# Centralized
GCP S3
AWS S3
Dropbox
...

```

## version 3.2
Has precompiled OPTIX kernels (much faster init time), is overall about 25-100% faster compared to 2.93. 

```
#Default to using OPTIX

curl -H "Content-Type: application/json" \
-X POST http://{node_ip_port}/job_create -d @- << EOF
{
    "owner": "zYbvEtzrYG9orosMLrdjmuXTvVmJGHEDBNAfWNRDqre",
    "job": {
        "type": "docker",
        "meta": {"subtype":"blender"},
        "cpu": 40,
        "ram": 32,
        "disk": 30,
        "gpu": [{"index":0,"name":"geforce rtx 3060"},{"index":1,"name":"geforce rtx 3060"}],
        "path": "docker.io/nytimes/blender:3.2-gpu-ubuntu18.04",
        "start_cmd": "wget -q https://raw.githubusercontent.com/gpuedge/examples/main/blender/bootstrap.sh && chmod +x bootstrap.sh && ./bootstrap.sh gpux://4FWrow8vhpCVnY8B1DGZNyx4SF6U GPUX OPTIX 1080 1350 1024"
    }
}
EOF
```