FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    libjsoncpp25 \
    libavcodec58 \
    libavformat58 \
    libavutil56 \
    libswscale5 \
    ffmpeg \
    ca-certificates \
    iputils-ping \
    net-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY build/server ./server

RUN chmod +x ./server

ENTRYPOINT ["./server"]