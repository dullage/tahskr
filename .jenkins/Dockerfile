FROM node:stretch

RUN apt update && apt install -y \
    wine64 \
    zip \
    unzip \
    jq \
    curl \
    file \
    rsync \
 && rm -rf /var/lib/apt/lists/*

ENTRYPOINT /bin/bash
