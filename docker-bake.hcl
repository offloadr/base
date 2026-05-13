variable "DOCKER_REGISTRY_URL" {
    default = "ghcr.io/offloadr/base/"
}
variable "PYTHON_VERSIONS" {
    default = ["3.12", "3.13"]
}
variable "CPU_RUNTIME_IMAGE" {
    default = "ubuntu:24.04"
}
variable "UV_VERSION" {
    default = "0.11.12"
}
variable "TORCH_VERSIONS" {
    default = ["2.10.0", "2.11.0"]
}
variable "TORCHVISION_VERSIONS" {
    default = {
        "2.10.0" = "0.25.0"
        "2.11.0" = "0.26.0"
    }
}
variable "NVIDIA_CUDA_VERSION" {
    default = "13.0.3"
}
variable "NVIDIA_CUDA_RUNTIME_IMAGE" {
    default = "nvidia/cuda:13.0.3-runtime-ubuntu24.04"
}
variable "NVIDIA_CUDA_DEVEL_IMAGE" {
    default = "nvidia/cuda:13.0.3-devel-ubuntu24.04"
}
variable "NVIDIA_TORCH_FLAVOR" {
    default = "cu130"
}
variable "AMD_ROCM_VERSIONS" {
    default = {
        "2.10.0" = "7.1.1"
        "2.11.0" = "7.2.3"
    }
}
variable "AMD_ROCM_IMAGES" {
    default = {
        "2.10.0" = "rocm/dev-ubuntu-24.04:7.1.1"
        "2.11.0" = "rocm/dev-ubuntu-24.04:7.2.3"
    }
}
variable "AMD_TORCH_FLAVORS" {
    default = {
        "2.10.0" = "rocm7.1"
        "2.11.0" = "rocm7.2"
    }
}
variable "CPU_TORCH_FLAVOR" {
    default = "cpu"
}

group "default" {
    targets = [
        "cpu-core",
        "amd-core",
        "amd-full",
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
    name = "nvidia-cache-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.nvidia.builder"
    args = {
        CUDA_DEVEL_IMAGE = "${NVIDIA_CUDA_DEVEL_IMAGE}"
        PYTHON_VERSION   = python_version
        UV_VERSION       = "${UV_VERSION}"
        TORCH_VERSION    = torch_version
        TORCHVISION_VERSION = TORCHVISION_VERSIONS[torch_version]
        TORCH_FLAVOR     = "${NVIDIA_TORCH_FLAVOR}"
    }
    platforms  = ["linux/amd64"]
    tags       = [
        "${DOCKER_REGISTRY_URL}nvidia-cache:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}",
        "${DOCKER_REGISTRY_URL}nvidia-builder:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}",
    ]
    cache-from = [
        "type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-cache:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}",
        "type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}",
    ]
    cache-to   = ["type=inline"]
}

target "nvidia-sageattention" {
    name = "nvidia-sageattention-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.nvidia.sageattention"
    contexts = {
        builder = "target:nvidia-cache-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:sageattention-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:sageattention-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "nvidia-nunchaku" {
    name = "nvidia-nunchaku-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.nvidia.nunchaku"
    contexts = {
        builder = "target:nvidia-cache-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:nunchaku-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:nunchaku-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "nvidia-xformers" {
    name = "nvidia-xformers-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.nvidia.xformers"
    contexts = {
        builder = "target:nvidia-cache-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:xformers-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:xformers-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "nvidia-flashattention" {
    name = "nvidia-flashattention-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.nvidia.flashattention"
    contexts = {
        builder = "target:nvidia-cache-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-builder:flashattention-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-builder:flashattention-py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "nvidia-core" {
    name = "nvidia-core-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.nvidia.core"
    args = {
        CUDA_RUNTIME_IMAGE = "${NVIDIA_CUDA_RUNTIME_IMAGE}"
        PYTHON_VERSION     = python_version
        UV_VERSION         = "${UV_VERSION}"
        TORCH_VERSION      = torch_version
        TORCHVISION_VERSION = TORCHVISION_VERSIONS[torch_version]
        TORCH_FLAVOR       = "${NVIDIA_TORCH_FLAVOR}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-core:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-core:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "nvidia-full" {
    name = "nvidia-full-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.nvidia.full"
    contexts = {
        nvidia-core   = "target:nvidia-core-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
        sageattention = "target:nvidia-sageattention-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
        nunchaku      = "target:nvidia-nunchaku-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
        xformers      = "target:nvidia-xformers-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
        flashattention = "target:nvidia-flashattention-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    }
    args = {
        NVIDIA_CORE_IMAGE = "nvidia-core"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}nvidia-full:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}nvidia-full:py${python_version}-torch${torch_version}-cuda${NVIDIA_CUDA_VERSION}"]
    cache-to   = ["type=inline"]
}

target "cpu-core" {
    name = "cpu-core-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.cpu.base"
    args = {
        CPU_RUNTIME_IMAGE = "${CPU_RUNTIME_IMAGE}"
        PYTHON_VERSION    = python_version
        UV_VERSION        = "${UV_VERSION}"
        TORCH_VERSION     = torch_version
        TORCHVISION_VERSION = TORCHVISION_VERSIONS[torch_version]
        TORCH_FLAVOR      = "${CPU_TORCH_FLAVOR}"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}cpu-core:py${python_version}-torch${torch_version}-cpu"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}cpu-core:py${python_version}-torch${torch_version}-cpu"]
    cache-to   = ["type=inline"]
}

target "amd-core" {
    name = "amd-core-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.amd.base"
    args = {
        ROCM_IMAGE      = AMD_ROCM_IMAGES[torch_version]
        PYTHON_VERSION  = python_version
        UV_VERSION      = "${UV_VERSION}"
        TORCH_VERSION   = torch_version
        TORCHVISION_VERSION = TORCHVISION_VERSIONS[torch_version]
        TORCH_FLAVOR    = AMD_TORCH_FLAVORS[torch_version]
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}amd-core:py${python_version}-torch${torch_version}-rocm${AMD_ROCM_VERSIONS[torch_version]}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}amd-core:py${python_version}-torch${torch_version}-rocm${AMD_ROCM_VERSIONS[torch_version]}"]
    cache-to   = ["type=inline"]
}

target "amd-full" {
    name = "amd-full-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    matrix = {
        python_version = PYTHON_VERSIONS
        torch_version  = TORCH_VERSIONS
    }
    context = "src"
    dockerfile = "dockerfile.amd.full"
    contexts = {
        amd-core = "target:amd-core-py${replace(python_version, ".", "")}-torch${replace(torch_version, ".", "")}"
    }
    args = {
        AMD_CORE_IMAGE = "amd-core"
    }
    platforms  = ["linux/amd64"]
    tags       = ["${DOCKER_REGISTRY_URL}amd-full:py${python_version}-torch${torch_version}-rocm${AMD_ROCM_VERSIONS[torch_version]}"]
    cache-from = ["type=registry,ref=${DOCKER_REGISTRY_URL}amd-full:py${python_version}-torch${torch_version}-rocm${AMD_ROCM_VERSIONS[torch_version]}"]
    cache-to   = ["type=inline"]
}
