variable "DOCKER_REGISTRY_URL" {
    default = "ghcr.io/offloadr/base/"
}
variable "PYTHON_VERSION" {
    default = "3.12"
}
variable "CPU_RUNTIME_IMAGE" {
    default = "ubuntu:24.04"
}
variable "UV_VERSION" {
    default = "0.11.2"
}
variable "TORCH_VERSION" {
    default = "2.10.0"
}
variable "NVIDIA_CUDA_VERSION" {
    default = "13.0.2"
}
variable "NVIDIA_CUDA_RUNTIME_IMAGE" {
    default = "nvidia/cuda:13.0.2-runtime-ubuntu24.04"
}
variable "NVIDIA_CUDA_DEVEL_IMAGE" {
    default = "nvidia/cuda:13.0.2-devel-ubuntu24.04"
}
variable "NVIDIA_TORCH_FLAVOR" {
    default = "cu130"
}
variable "AMD_ROCM_VERSION" {
    default = "7.1.1"
}
variable "AMD_ROCM_IMAGE" {
    default = "rocm/dev-ubuntu-24.04:7.1.1"
}
variable "AMD_TORCH_FLAVOR" {
    default = "rocm7.1"
}
variable "CPU_TORCH_FLAVOR" {
    default = "cpu"
}

group "default" {
    targets = [
        "cpu-core",
        "amd-core",
        "nvidia-core",
        "nvidia-full",
    ]
}

group "nvidia-public" {
    targets = [
        "nvidia-core",
        "nvidia-full",
    ]
}

target "nvidia-cache" {
    context = "src"
    dockerfile = "dockerfile.nvidia.builder"
    args = {
        CUDA_DEVEL_IMAGE = "${NVIDIA_CUDA_DEVEL_IMAGE}"
        PYTHON_VERSION   = "${PYTHON_VERSION}"
        UV_VERSION       = "${UV_VERSION}"
        TORCH_VERSION    = "${TORCH_VERSION}"
        TORCH_FLAVOR     = "${NVIDIA_TORCH_FLAVOR}"
    }
    platforms  = ["linux/amd64"]
    tags       = [
        "${DOCKER_REGISTRY_URL}nvidia-cache:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cuda${NVIDIA_CUDA_VERSION}",
        "${DOCKER_REGISTRY_URL}nvidia-builder:latest",
    ]
    cache-from = [
        "type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-cache:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cuda${NVIDIA_CUDA_VERSION}",
        "type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:latest",
    ]
    cache-to   = ["type=inline"]
}

target "nvidia-sageattention" {
    context = "src"
    dockerfile = "dockerfile.nvidia.sageattention"
    contexts = {
        builder = "target:nvidia-cache"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:sageattention"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:sageattention"]
    cache-to   = ["type=inline"]
}

target "nvidia-nunchaku" {
    context = "src"
    dockerfile = "dockerfile.nvidia.nunchaku"
    contexts = {
        builder = "target:nvidia-cache"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:nunchaku"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:nunchaku"]
    cache-to   = ["type=inline"]
}

target "nvidia-xformers" {
    context = "src"
    dockerfile = "dockerfile.nvidia.xformers"
    contexts = {
        builder = "target:nvidia-cache"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:xformers"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:xformers"]
    cache-to   = ["type=inline"]
}

target "nvidia-flashattention" {
    context = "src"
    dockerfile = "dockerfile.nvidia.flashattention"
    contexts = {
        builder = "target:nvidia-cache"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:flashattention"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:flashattention"]
    cache-to   = ["type=inline"]
}

target "nvidia-core" {
    context = "src"
    dockerfile = "dockerfile.nvidia.core"
    args = {
        CUDA_RUNTIME_IMAGE = "${NVIDIA_CUDA_RUNTIME_IMAGE}"
        PYTHON_VERSION     = "${PYTHON_VERSION}"
        UV_VERSION         = "${UV_VERSION}"
        TORCH_VERSION      = "${TORCH_VERSION}"
        TORCH_FLAVOR       = "${NVIDIA_TORCH_FLAVOR}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-core:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-core:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "nvidia-full" {
    context = "src"
    dockerfile = "dockerfile.nvidia.full"
    contexts = {
        nvidia-core   = "target:nvidia-core"
        sageattention = "target:nvidia-sageattention"
        nunchaku      = "target:nvidia-nunchaku"
        xformers      = "target:nvidia-xformers"
        flashattention = "target:nvidia-flashattention"
    }
    args = {
        NVIDIA_CORE_IMAGE = "nvidia-core"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-full:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-full:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "cpu-core" {
    context = "src"
    dockerfile = "dockerfile.cpu.base"
    args = {
        CPU_RUNTIME_IMAGE = "${CPU_RUNTIME_IMAGE}"
        PYTHON_VERSION    = "${PYTHON_VERSION}"
        UV_VERSION        = "${UV_VERSION}"
        TORCH_VERSION     = "${TORCH_VERSION}"
        TORCH_FLAVOR      = "${CPU_TORCH_FLAVOR}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}cpu-core:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cpu"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}cpu-core:py${PYTHON_VERSION}-torch${TORCH_VERSION}-cpu"]
    cache-to   = ["type=inline"]
}

target "amd-core" {
    context = "src"
    dockerfile = "dockerfile.amd.base"
    args = {
        ROCM_IMAGE      = "${AMD_ROCM_IMAGE}"
        PYTHON_VERSION  = "${PYTHON_VERSION}"
        UV_VERSION      = "${UV_VERSION}"
        TORCH_VERSION   = "${TORCH_VERSION}"
        TORCH_FLAVOR    = "${AMD_TORCH_FLAVOR}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}amd-core:py${PYTHON_VERSION}-torch${TORCH_VERSION}-rocm${AMD_ROCM_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}amd-core:py${PYTHON_VERSION}-torch${TORCH_VERSION}-rocm${AMD_ROCM_VERSION}"]
    cache-to   = ["type=inline"]
}
