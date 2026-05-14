# Этап сборки
FROM rust:slim AS builder
ARG WASM_PACK_VERSION=0.14.0
RUN apt-get update && apt-get install -y \
    clang libssl-dev pkg-config build-essential git ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*
RUN cargo install --locked --version ${WASM_PACK_VERSION} wasm-pack
WORKDIR /build
RUN git clone --depth 1 --branch master https://github.com/vectordotdev/vector.git
WORKDIR /build/vector/lib/vector-vrl/web-playground
RUN wasm-pack build --target web --out-dir public/pkg --release

# Этап runtime
FROM alpine:latest AS runtime
RUN apk add --no-cache nginx
COPY nginx/mime.types /etc/nginx/mime.types
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/ /etc/nginx/conf.d/
RUN mkdir -p /var/www/public
COPY --from=builder /build/vector/lib/vector-vrl/web-playground/public /var/www/public
EXPOSE 8082
CMD ["nginx", "-g", "daemon off;"]
