FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# System packages
#   - ESDK runtime: libssl3, libcurl4, libjsoncpp25
#   - FFmpeg runtime: libav* (matches Ubuntu 22.04 package versions)
#   - RTSP stream: ffmpeg binary
#   - MQTT broker: mosquitto
#   - Telemetry bridge: python3, pip, paho-mqtt
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    libjsoncpp25 \
    libavcodec58 \
    libavformat58 \
    libavutil56 \
    libswscale5 \
    ffmpeg \
    mosquitto \
    python3 \
    python3-pip \
    ca-certificates \
    iputils-ping \
    net-tools \
    curl \
    && rm -rf /var/lib/apt/lists/*

# paho-mqtt for the telemetry bridge sidecar
RUN pip3 install --no-cache-dir paho-mqtt==1.6.1

# ---------------------------------------------------------------------------
# mediamtx — RTSP server
# FFmpeg publishes the H.264 stream here; external clients pull from here.
# ---------------------------------------------------------------------------
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then MTX_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then MTX_ARCH="arm64v8"; \
    else echo "Unsupported arch: $ARCH" && exit 1; fi && \
    MTX_VERSION="v1.9.3" && \
    curl -fsSL \
      "https://github.com/bluenviron/mediamtx/releases/download/${MTX_VERSION}/mediamtx_${MTX_VERSION}_linux_${MTX_ARCH}.tar.gz" \
      | tar xz -C /usr/local/bin mediamtx && \
    chmod +x /usr/local/bin/mediamtx

# ---------------------------------------------------------------------------
# Mosquitto config
# ---------------------------------------------------------------------------
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf
RUN mkdir -p /var/lib/mosquitto && chown mosquitto:mosquitto /var/lib/mosquitto

WORKDIR /app

# ESDK server binary (built on the host via BuildCommand.txt)
COPY build/server ./server
RUN chmod +x ./server

# Telemetry bridge sidecar
COPY telemetry_bridge.py ./telemetry_bridge.py

# Entrypoint starts: mosquitto → mediamtx → telemetry_bridge → server
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# 8554 = RTSP (mediamtx, for video consumers)
# 1883 = MQTT (mosquitto, for telemetry consumers)
EXPOSE 8554 1883

ENTRYPOINT ["./entrypoint.sh"]