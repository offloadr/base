# Offloadr Base Images

This repository builds reusable hardware/runtime base images for downstream application images.

## Published images

The public image contract is:

* `ghcr.io/offloadr/base/cpu-core`
* `ghcr.io/offloadr/base/amd-core`
* `ghcr.io/offloadr/base/nvidia-core`
* `ghcr.io/offloadr/base/nvidia-full`

## Default tags

The default tags built by this repository are built for Python 3.12 and 3.13 with PyTorch 2.10.0 and 2.11.0:

* `cpu-core:py3.12-torch2.10.0-cpu`
* `cpu-core:py3.13-torch2.10.0-cpu`
* `cpu-core:py3.12-torch2.11.0-cpu`
* `cpu-core:py3.13-torch2.11.0-cpu`
* `amd-core:py3.12-torch2.10.0-rocm7.1.1`
* `amd-core:py3.13-torch2.10.0-rocm7.1.1`
* `amd-core:py3.12-torch2.11.0-rocm7.2.3`
* `amd-core:py3.13-torch2.11.0-rocm7.2.3`
* `nvidia-core:py3.12-torch2.10.0-cuda13.0.3`
* `nvidia-core:py3.13-torch2.10.0-cuda13.0.3`
* `nvidia-core:py3.12-torch2.11.0-cuda13.0.3`
* `nvidia-core:py3.13-torch2.11.0-cuda13.0.3`
* `nvidia-full:py3.12-torch2.10.0-cuda13.0.3`
* `nvidia-full:py3.13-torch2.10.0-cuda13.0.3`
* `nvidia-full:py3.12-torch2.11.0-cuda13.0.3`
* `nvidia-full:py3.13-torch2.11.0-cuda13.0.3`

## Runtime contract

All published runtime images are expected to provide:

* `WORKDIR /workspace`
* system `python`
* `uv` 0.11.12
* built-in virtual environment at `/opt/venv` with the base Python packages

## NVIDIA variants

`nvidia-full` also contains these accelerator packages in the built-in venv:

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

Build a specific Python flavor:

```shell
docker buildx bake nvidia-full-py312-torch2110
```
