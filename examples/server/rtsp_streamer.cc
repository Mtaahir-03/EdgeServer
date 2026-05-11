#include "rtsp_streamer.h"

#include <iostream>
#include <cstdio>

RTSPStreamer::RTSPStreamer() {
    ffmpeg_pipe_ = nullptr;
}

RTSPStreamer::~RTSPStreamer() {
    if (ffmpeg_pipe_) {
        pclose(ffmpeg_pipe_);
    }
}

bool RTSPStreamer::Start() {

    const char* cmd =
        "ffmpeg "
        "-nostdin "
        "-loglevel warning "
        "-re "
        "-f h264 "
        "-i - "
        "-c copy "
        "-f rtsp "
        "-rtsp_transport tcp "
        "rtsp://127.0.0.1:8554/live";

    ffmpeg_pipe_ = popen(cmd, "w");

    if (!ffmpeg_pipe_) {
        std::cerr << "Failed to start FFmpeg\n";
        return false;
    }

    std::cout << "RTSP stream ready:\n";
    std::cout << "rtsp://<EDGE-IP>:8554/live\n";

    return true;
}

void RTSPStreamer::PushFrame(
    const uint8_t* data,
    size_t len) {

    if (!ffmpeg_pipe_)
        return;

    fwrite(data, 1, len, ffmpeg_pipe_);

    fflush(ffmpeg_pipe_);
}