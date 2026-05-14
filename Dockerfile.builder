FROM rust:slim AS builder

ARG WASM_PACK_VERSION=0.14.0
ARG VECTOR_REPO=https://github.com/vectordotdev/vector.git
ARG VECTOR_COMMIT=master

# Установка ВСЕХ необходимых системных зависимостей
RUN apt-get update && apt-get install -y \
    clang \
    libssl-dev \
    pkg-config \
    build-essential \
    git \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Установка wasm-pack из локального архива
RUN cargo install --locked --version ${WASM_PACK_VERSION} wasm-pack

# Vector
WORKDIR /build
RUN git clone --depth 1 --branch master https://github.com/vectordotdev/vector.git

WORKDIR /build/vector/lib/vector-vrl/web-playground
RUN wasm-pack build --target web --out-dir public/pkg --release
