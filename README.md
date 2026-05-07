# Offloadr Base Images

This repository builds reusable hardware/runtime base images for downstream application images.

## Published images

The public image contract is:

* `ghcr.io/offloadr/base/cpu-core`
* `ghcr.io/offloadr/base/amd-core`
* `ghcr.io/offloadr/base/nvidia-core`
* `ghcr.io/offloadr/base/nvidia-full`

## Default tags

The default immutable tags built by this repository are:

* `cpu-core:py3.12-torch2.10.0-cpu`
* `amd-core:py3.12-torch2.10.0-rocm7.1.1`
* `nvidia-core:py3.12-torch2.10.0-cuda13.0.2`
* `nvidia-full:py3.12-torch2.10.0-cuda13.0.2`

## Runtime contract

All published runtime images are expected to provide:

* `WORKDIR /workspace`
* system `python`
* `uv` 0.11.7
* baked uv cache at `/opt/uv-cache`

Base Python packages are not installed into the system Python environment. Downstream
entrypoints should create their runtime virtual environment as the runtime user and install
from the baked uv cache.

## NVIDIA variants

`nvidia-core` contains CUDA, Python, `uv`, and a baked uv cache containing PyTorch plus
the shared Python dependencies needed by the optional accelerator wheels.

`nvidia-full` adds `/opt/offloadr-wheelhouse` with:

* xFormers
* FlashAttention 3
* SageAttention2++
* Nunchaku

## Building

Build everything locally:

```shell
docker buildx bake
```

Build a specific image:

```shell
docker buildx bake nvidia-full
```
