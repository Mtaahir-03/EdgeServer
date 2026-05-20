#!/bin/bash
set -e

# =============================================================================
# Edge Server Entrypoint
#
# Start order matters:
#   1. mosquitto        — local MQTT broker (must be up before the bridge
#                         tries to publish to it)
#   2. mediamtx         — RTSP server (must be up before FFmpeg connects)
#   3. telemetry_bridge — subscribes to FlightHub OSD, publishes to Mosquitto
#   4. server           — ESDK process (starts FFmpeg when drone connects)
# =============================================================================

log() { echo "[entrypoint] $*"; }

# ---------------------------------------------------------------------------
# 1. Start local Mosquitto broker
# ---------------------------------------------------------------------------
log "Starting Mosquitto broker on port 1883..."
mosquitto -c /etc/mosquitto/mosquitto.conf -d
sleep 1

# ---------------------------------------------------------------------------
# 2. Start mediamtx (RTSP server)
# ---------------------------------------------------------------------------
log "Starting mediamtx RTSP server on port 8554..."
mediamtx &
MEDIAMTX_PID=$!
sleep 1

# ---------------------------------------------------------------------------
# 3. Start telemetry bridge
# ---------------------------------------------------------------------------
log "Starting telemetry bridge..."
python3 /app/telemetry_bridge.py &
BRIDGE_PID=$!

# ---------------------------------------------------------------------------
# 4. Start the ESDK edge server
# ---------------------------------------------------------------------------
log "Starting edge server..."
./server
SERVER_EXIT=$?

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
log "Server exited (rc=$SERVER_EXIT), shutting down..."
kill $BRIDGE_PID   2>/dev/null || true
kill $MEDIAMTX_PID 2>/dev/null || true
pkill mosquitto    2>/dev/null || true

exit $SERVER_EXIT