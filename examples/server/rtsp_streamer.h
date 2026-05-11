#ifndef __RTSP_STREAMER_H__
#define __RTSP_STREAMER_H__

#include <cstdio>
#include <cstdint>

class RTSPStreamer {
public:
    RTSPStreamer();
    ~RTSPStreamer();

    bool Start();

    void PushFrame(
        const uint8_t* data,
        size_t len);

private:
    FILE* ffmpeg_pipe_;
};

#endif