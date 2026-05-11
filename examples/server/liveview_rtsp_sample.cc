#include "liveview_rtsp_sample.h"

#include <thread>
#include <unistd.h>

using namespace edge_sdk;

namespace edge_app {

LiveviewRTSPSample::LiveviewRTSPSample() {
    liveview_ = edge_sdk::CreateLiveview();
    liveview_status_ = (Liveview::LiveviewStatus)0;
}

ErrorCode LiveviewRTSPSample::StreamCallback(
    const uint8_t* data,
    size_t len) {

    rtsp_streamer_.PushFrame(data, len);

    return kOk;
}

ErrorCode LiveviewRTSPSample::Init(
    Liveview::CameraType type,
    Liveview::StreamQuality quality) {

    auto stream_callback =
        std::bind(
            &LiveviewRTSPSample::StreamCallback,
            this,
            std::placeholders::_1,
            std::placeholders::_2);

    Liveview::Options option = {
        type,
        quality,
        stream_callback
    };

    auto rc = liveview_->Init(option);

    liveview_->SubscribeLiveviewStatus(
        std::bind(
            &LiveviewRTSPSample::LiveviewStatusCallback,
            this,
            std::placeholders::_1));

    rtsp_streamer_.Start();

    return rc;
}

ErrorCode LiveviewRTSPSample::Start() {

    std::thread([&] {

        while (liveview_status_ == 0)
            sleep(1);

        auto rc = liveview_->StartH264Stream();

        if (rc != kOk) {
            printf("Failed to start stream\n");
        }

    }).detach();

    return kOk;
}

void LiveviewRTSPSample::LiveviewStatusCallback(
    const Liveview::LiveviewStatus& status) {

    liveview_status_ = status;

    printf("Liveview status: %d\n", status);
}

}