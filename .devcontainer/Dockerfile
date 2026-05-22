FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        clang \
        curl \
        gzip \
        make \
        nasm \
        netcat-openbsd \
        novnc \
        qemu-system-x86 \
        unzip \
        websockify \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
