# Jupyter

## Packages included

Build
```
podman login docker.io
podman build --squash-all --tag vans163/jupyter:v4 .
podman push --format oci --compression-format zstd:chunked vans163/jupyter:v4
```

System
```
apt-transport-https apt-utils
vim git curl wget locate locales
python3 python3-pip
```

Pip
```
numpy scipy sklearn tensorflow torch pandas matplotlib jax
jupyterlab
```
