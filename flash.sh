#!/usr/bin/env bash
# Flash a previously built firmware to the device (invokes build.sh first)
# Usage: ./flash.sh <firmware.hex> [port]
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
	echo "Usage: $0 <firmware.hex> [port]"
	exit 1
fi


HEX="$1"
if [[ ! -f "$HEX" ]]; then
  echo "Error: file not found: $HEX"
  exit 1
fi

# Build first (calls build.sh in the same directory)
PROGRAMMER="${PROGRAMMER:-arduino}"
BAUD="${BAUD:-115200}"
PORT="${2:-${PORT:-}}"
MCU="${MCU:-atmega328p}"

if [[ -z "$PORT" ]]; then
  for p in /dev/ttyACM0 /dev/ttyACM1 /dev/ttyUSB0 /dev/ttyUSB1; do
    [[ -e "$p" ]] && PORT="$p" && break
  done
fi

if [[ -z "$PORT" ]]; then
  echo "Error: no serial port found. Set PORT=/dev/ttyACM0, or pass it as second arg."
  exit 1
fi

avrdude -v -p "$MCU" -c "$PROGRAMMER" -P "$PORT" -b "$BAUD" -D -U "flash:w:$HEX:i"

echo "Flashed $HEX to $PORT"