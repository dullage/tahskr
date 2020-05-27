FROM node:stretch-slim

RUN apt update && apt install -y \
    wine64 \
    zip \
    unzip \
    jq \
    curl \
    file \
 && rm -rf /var/lib/apt/lists/*

ENTRYPOINT /bin/bash
