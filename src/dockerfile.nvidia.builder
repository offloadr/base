ARG CUDA_DEVEL_IMAGE
FROM ${CUDA_DEVEL_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/offloadr/base"

ARG PYTHON_VERSION
ARG UV_VERSION
ARG TORCH_VERSION
ARG TORCHVISION_VERSION
ARG TORCH_FLAVOR

RUN test -n "${PYTHON_VERSION}" && \
    test -n "${UV_VERSION}" && \
    test -n "${TORCH_VERSION}" && \
    test -n "${TORCHVISION_VERSION}" && \
    test -n "${TORCH_FLAVOR}"

# Install required native build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
ADD https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz /tmp/uv.tar.gz
RUN tar -xzf /tmp/uv.tar.gz --strip-components=1 && \
    mv uv /usr/local/bin/uv && \
    rm -rf /tmp/uv.tar.gz

# Configure uv cache to work with Docker BuildKit cache
ENV UV_CACHE_DIR=/cache/uv
ENV UV_LINK_MODE=copy
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
ENV UV_PYTHON_BIN_DIR=/usr/local/bin
ENV OFFLOADR_BUILDER_VENV=/opt/builder-venv
ENV OFFLOADR_TORCH_VERSION=${TORCH_VERSION}
ENV OFFLOADR_TORCHVISION_VERSION=${TORCHVISION_VERSION}
ENV OFFLOADR_TORCH_FLAVOR=${TORCH_FLAVOR}
ENV OFFLOADR_TORCH_INDEX_URL=https://download.pytorch.org/whl/${TORCH_FLAVOR}
ENV UV_CONSTRAINT=/opt/offloadr/constraints/torch-stack.txt
ENV VIRTUAL_ENV=${OFFLOADR_BUILDER_VENV}
ENV PATH=${OFFLOADR_BUILDER_VENV}/bin:${PATH}
RUN mkdir -p /opt/offloadr/constraints && \
    printf 'torch==%s\ntorchvision==%s\ntorchaudio==%s\n' \
        "${TORCH_VERSION}" "${TORCHVISION_VERSION}" "${TORCH_VERSION}" \
        > ${UV_CONSTRAINT}

# Install uv-managed CPython for extension builds
RUN --mount=type=cache,target=/cache/uv,sharing=locked \
    UV_PYTHON_CACHE_DIR=/cache/uv/python uv python install ${PYTHON_VERSION} --default && \
    uv venv --python /usr/local/bin/python${PYTHON_VERSION} ${OFFLOADR_BUILDER_VENV} && \
    ln -sf ${OFFLOADR_BUILDER_VENV}/bin/python /usr/bin/python

# Set a neutral workspace for build steps
WORKDIR /workspace

# Install PyTorch into the builder virtual environment
RUN --mount=type=cache,target=/cache/uv,sharing=locked \
    uv pip install \
    --python ${OFFLOADR_BUILDER_VENV}/bin/python \
    torch==${TORCH_VERSION} \
    torchvision==${TORCHVISION_VERSION} \
    torchaudio==${TORCH_VERSION} \
    --index-url https://download.pytorch.org/whl/${TORCH_FLAVOR}

RUN ${OFFLOADR_BUILDER_VENV}/bin/python -c "import importlib.metadata as m, os; \
assert m.version('torch').partition('+')[0] == os.environ['OFFLOADR_TORCH_VERSION']; \
assert m.version('torchvision').partition('+')[0] == os.environ['OFFLOADR_TORCHVISION_VERSION']; \
assert m.version('torchaudio').partition('+')[0] == os.environ['OFFLOADR_TORCH_VERSION']"

# Install build python packages
RUN --mount=type=cache,target=/cache/uv,sharing=locked \
    uv pip install --python ${OFFLOADR_BUILDER_VENV}/bin/python ninja wheel packaging
