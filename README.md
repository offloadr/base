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

* `cpu-core:py3.13-torch2.10.0-cpu`
* `amd-core:py3.13-torch2.10.0-rocm7.1.1`
* `nvidia-core:py3.13-torch2.10.0-cuda13.0.2`
* `nvidia-full:py3.13-torch2.10.0-cuda13.0.2`

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
