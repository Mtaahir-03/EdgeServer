cmake_minimum_required(VERSION 3.10)

project(edge_server)

set(CMAKE_CXX_STANDARD 17)

set(SOURCES
    main.cc
    liveview_rtsp_sample.cc
    rtsp_streamer.cc
)

add_executable(server ${SOURCES})

target_include_directories(server PRIVATE
    ../../include
)

target_link_libraries(server
    ../../lib/libedgesdk.a
    pthread
    dl
    rt
)
