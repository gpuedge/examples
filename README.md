# examples
Recipes and example for various workloads

## Docker Images

```
jupyter  - docker.io/vans163/jupyter:v3
livebook - docker.io/vans163/livebook:v2
```

## Build a private docker image
```
IMGID=$(podman build . | tail -n1)
OUTPUT=image.tar.zst

## this step is optional, if at runtime more dependencies are fetched
# podman run -it --cidfile ./cid $IMGID
## DO STUFF INSIDE
# CID=$(cat ./cid)
# podman stop $CID
# IMGID=$(podman commit $CID)

podman save --uncompressed $IMGID | pv | zstd -1 > $OUTPUT

XAPIKEY=<Make one on explorer>
curl -X POST -H "Filename: $OUTPUT" -T "$OUTPUT" http://explorer_upload.gpux.ai/api/storage/upload?xapikey=$XAPIKEY
```

Now to use it in job params for `explorer.gpux.ai`
```
{
    ...
    path: "gpuxpriv://image.tar.zst"
}
```