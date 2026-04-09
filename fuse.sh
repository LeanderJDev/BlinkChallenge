#!/usr/bin/env bash
# fuse.sh - safe fuse writer (mockup)
# Usage: PORT=/dev/ttyUSB0 ./fuse.sh [--dryrun]
set -euo pipefail

PORT="${PORT:-/dev/ttyUSB0}"
PROGRAMMER="${PROGRAMMER:-arduino}"
MCU="${MCU:-m328p}"
BAUD="${BAUD:-115200}"
DRYRUN=false

if [[ "${1:-}" == "--dryrun" ]]; then
  DRYRUN=true
fi

# Recommended defaults (Arduino Uno / Optiboot)
LFUSE="${LFUSE:-0xFF}"
HFUSE="${HFUSE:-0xDE}"
EFUSE="${EFUSE:-0x05}"

echo "Target: MCU=$MCU, programmer=$PROGRAMMER, port=$PORT, baud=$BAUD"
echo "Current planned fuses:"
echo "  LFUSE = $LFUSE"
echo "  HFUSE = $HFUSE"
echo "  EFUSE = $EFUSE"
echo
echo "WARNING: Wrong fuse values can brick your board. This script will overwrite fuses."
read -p "Type YES to continue and program these fuses: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
  echo "Aborted."
  exit 1
fi

if $DRYRUN; then
  echo "Dry run: would call avrdude to write fuses (not executing)."
  echo "avrdude -v -p $MCU -c $PROGRAMMER -P $PORT -b $BAUD -U lfuse:w:$LFUSE:m -U hfuse:w:$HFUSE:m -U efuse:w:$EFUSE:m"
  exit 0
fi

# Program fuses
avrdude -v -p "$MCU" -c "$PROGRAMMER" -P "$PORT" -b "$BAUD" \
  -U lfuse:w:"$LFUSE":m -U hfuse:w:"$HFUSE":m -U efuse:w:"$EFUSE":m

echo "Done. Verify with:"
echo "  avrdude -p $MCU -c $PROGRAMMER -P $PORT -b $BAUD -v"