#ifndef __LIVEVIEW_RTSP_SAMPLE_H__
#define __LIVEVIEW_RTSP_SAMPLE_H__

#include <atomic>
#include <chrono>

#include "liveview/liveview.h"
#include "error_code.h"

#include "rtsp_streamer.h"

namespace edge_app {

class LiveviewRTSPSample {
public:
    LiveviewRTSPSample();

    edge_sdk::ErrorCode Init(
        edge_sdk::Liveview::CameraType type,
        edge_sdk::Liveview::StreamQuality quality);

    edge_sdk::ErrorCode Start();

private:
    edge_sdk::ErrorCode StreamCallback(
        const uint8_t* data,
        size_t len);

    void LiveviewStatusCallback(
        const edge_sdk::Liveview::LiveviewStatus& status);

    std::shared_ptr<edge_sdk::Liveview> liveview_;

    edge_sdk::Liveview::LiveviewStatus liveview_status_;

    RTSPStreamer rtsp_streamer_;
};

}

#endif