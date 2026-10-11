# Offloadr Base Images

This repository builds reusable hardware/runtime base images for downstream application images.

## Published images

The public image contract is:

* `ghcr.io/offloadr/base/cpu-core`
* `ghcr.io/offloadr/base/amd-core`
* `ghcr.io/offloadr/base/amd-full`
* `ghcr.io/offloadr/base/nvidia-core`
* `ghcr.io/offloadr/base/nvidia-full`

## Default tags

The default tags use Python 3.12 and 3.13. NVIDIA uses PyTorch 2.14.1 with CUDA
13.0.3; CPU and AMD retain PyTorch 2.10.0 and 2.11.0:

* `cpu-core:py3.12-torch2.10.0-cpu`
* `cpu-core:py3.13-torch2.10.0-cpu`
* `cpu-core:py3.12-torch2.11.0-cpu`
* `cpu-core:py3.13-torch2.11.0-cpu`
* `amd-core:py3.12-torch2.10.0-rocm7.1.1`
* `amd-core:py3.13-torch2.10.0-rocm7.1.1`
* `amd-core:py3.12-torch2.11.0-rocm7.2.3`
* `amd-core:py3.13-torch2.11.0-rocm7.2.3`
* `amd-full:py3.12-torch2.10.0-rocm7.1.1`
* `amd-full:py3.13-torch2.10.0-rocm7.1.1`
* `amd-full:py3.12-torch2.11.0-rocm7.2.3`
* `amd-full:py3.13-torch2.11.0-rocm7.2.3`
* `nvidia-core:py3.12-torch2.14.1-cuda13.0.3`
* `nvidia-core:py3.13-torch2.14.1-cuda13.0.3`
* `nvidia-full:py3.12-torch2.14.1-cuda13.0.3`
* `nvidia-full:py3.13-torch2.14.1-cuda13.0.3`

## Runtime contract

All published runtime images are expected to provide:

* `WORKDIR /workspace`
* `python` command backed by uv-managed CPython
* `uv` 0.11.12
* built-in virtual environment at `/opt/venv` with the base Python packages
* `UV_CONSTRAINT=/opt/offloadr/constraints/torch-stack.txt` to pin `torch`,
  `torchvision`, and `torchaudio`

## AMD variants

`amd-full` also contains these accelerator packages in the built-in venv:

* xFormers

## NVIDIA variants

`nvidia-full` also contains these accelerator packages in the built-in venv:

* xFormers
* SageAttention2++

The runtime starts from NVIDIA's minimal CUDA `base` image. PyTorch's CUDA
wheels supply the math libraries, avoiding a second copy from NVIDIA's larger
`runtime` image. Extension builders retain the CUDA `devel` image.

Nunchaku is no longer bundled. Install it only in downstream images that need
its specialized models and custom nodes.

FlashAttention 3 is excluded from `nvidia-full`: it requires Hopper GPUs and
adds a large binary package that Ampere and Ada GPUs cannot use. The opt-in
`nvidia-hopper` image extends `nvidia-full` with FlashAttention 3 in a separate
layer. Its tags use the same Python/PyTorch/CUDA suffixes, for example
`nvidia-hopper:py3.12-torch2.14.1-cuda13.0.3`.

The default build and CI exclude the Hopper image and its FlashAttention wheel
builder. To publish it, run the main-branch workflow manually with
`build_hopper` enabled. Existing published tags retain their old components
until rebuilt; downstream application images must then be rebuilt against the
new base to benefit from the reduced size.

## NVIDIA drivers and cloud hosts

The host provides the NVIDIA driver; the image provides its CUDA runtime. A
matching host CUDA Toolkit installation is not required. For Vast.ai, RunPod,
QuickPod, Shadeform and similar rentals, select a host advertising CUDA 13.0 or
newer (driver branch R580 or newer). Check the actual driver capability before
renting; a template's installed CUDA Toolkit version is not the driver limit.

CUDA 13.0 keeps the driver requirement lower than CUDA 13.2 while supporting the
current ComfyUI stack. Hosts below CUDA 13.0 need a separately maintained older
runtime. [NVIDIA's compatibility documentation](https://docs.nvidia.com/deploy/cuda-compatibility/minor-version-compatibility.html)
explains driver requirements and PTX/JIT limitations.

PyTorch and torchvision are pinned to their `cu130` wheels, including the CUDA
suffix in the inherited constraints. TorchAudio 2.11.0 is installed separately
from PyPI: [it supports PyTorch 2.11 and later](https://github.com/pytorch/audio).
xFormers and optional FlashAttention 3 use stable-ABI CUDA 13 wheels published
in the `cu130` index; SageAttention is built with the CUDA 13.0 toolkit. Builds
check package versions, Torch's CUDA flavor and accelerator imports without
requiring a GPU. Actual attention kernels still need GPU validation.

Publish the new base tags before updating downstream image builds to use them.

## Building

Build the standard images locally:

```shell
docker buildx bake
```

Build a specific image:

```shell
docker buildx bake nvidia-full
```

Build a specific Python and PyTorch flavor:

```shell
docker buildx bake nvidia-full-py312-torch2141
```

Build the opt-in Hopper image (also builds its standard-image dependencies):

```shell
docker buildx bake nvidia-hopper-py312-torch2141
```
