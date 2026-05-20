FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        clang \
        curl \
        make \
        nasm \
        netcat-openbsd \
        novnc \
        python3 \
        qemu-system-x86 \
        websockify \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
