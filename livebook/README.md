# Livebook

## Packages included

Build
```
podman login docker.io
podman build --tag vans163/livebook:v3 .
podman push vans163/livebook:v3
```

Run
```
set ENVVARS for pod to 

LIVEBOOK_IP=0.0.0.0 LIVEBOOK_DATA_PATH=/gpux_usr LIVEBOOK_HOME=/gpux_usr LIVEBOOK_TOKEN_ENABLED=false
```
