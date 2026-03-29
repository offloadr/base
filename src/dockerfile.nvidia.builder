ARG CUDA_DEVEL_IMAGE
FROM ${CUDA_DEVEL_IMAGE}

ARG PYTHON_VERSION
ARG UV_VERSION
ARG TORCH_VERSION
ARG TORCH_FLAVOR

RUN test -n "${PYTHON_VERSION}" && \
    test -n "${UV_VERSION}" && \
    test -n "${TORCH_VERSION}" && \
    test -n "${TORCH_FLAVOR}"

# Install required native build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} python${PYTHON_VERSION}-dev git \
    && ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Install uv
ADD https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz /tmp/uv.tar.gz
RUN tar -xzf /tmp/uv.tar.gz --strip-components=1 && \
    mv uv /usr/local/bin/uv && \
    rm -rf /tmp/uv.tar.gz

# Configure uv cache to work with Docker BuildKit cache
ENV UV_CACHE_DIR=/cache/uv
ENV UV_LINK_MODE=copy
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

# Set a neutral workspace for build steps
WORKDIR /workspace

# Prepare the virtual environment
RUN uv venv "${VIRTUAL_ENV}"

# Install pytorch
RUN --mount=type=cache,target=/cache/uv,sharing=locked \
    uv pip install \
    --python "${VIRTUAL_ENV}/bin/python" \
    torch==${TORCH_VERSION} \
    torchvision \
    torchaudio \
    --index-url https://download.pytorch.org/whl/${TORCH_FLAVOR}

# Install build python packages
RUN --mount=type=cache,target=/cache/uv,sharing=locked \
    uv pip install --python "${VIRTUAL_ENV}/bin/python" ninja wheel packaging
