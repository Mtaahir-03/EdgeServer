#include <iostream>
#include <thread>

#include "liveview_rtsp_sample.h"

using namespace edge_app;

int main() {

    std::cout << "Starting Edge Application\n";

    auto liveview =
        std::make_shared<LiveviewRTSPSample>();

    auto rc =
        liveview->Init(
            edge_sdk::Liveview::CameraType::kCameraTypeFpv,
            edge_sdk::Liveview::StreamQuality::kStreamQuality1080pHigh);

    if (rc != edge_sdk::kOk) {
        std::cout << "Liveview init failed\n";
        return -1;
    }

    liveview->Start();

    while (true) {
        std::this_thread::sleep_for(
            std::chrono::seconds(1));
    }

    return 0;
}