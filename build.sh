#!/usr/bin/env bash
# Build (assemble, link, objcopy) an AVR assembler firmware file
# Usage: ./build.sh <firmware.s>
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <firmware.s>"
  exit 1
fi

SRC="$1"
if [[ ! -f "$SRC" ]]; then
  echo "Error: file not found: $SRC"
  exit 1
fi

BASE="${SRC%.s}"
OBJ="${BASE}.o"
ELF="${BASE}.elf"
HEX="${BASE}.hex"

MCU="${MCU:-atmega328p}"
F_CPU="${F_CPU:-16000000UL}"

echo "Building $SRC -> $HEX (MCU=$MCU, F_CPU=$F_CPU)"

avr-gcc -mmcu="$MCU" -DF_CPU="$F_CPU" -x assembler-with-cpp -c "$SRC" -o "$OBJ"
## Link without standard start files so the interrupt vector table comes
## only from the objects you provide. This avoids pulling in libc/crt
## startup code that would add many default vectors.
avr-gcc -mmcu="$MCU" -nostartfiles "$OBJ" -o "$ELF"
avr-objcopy -O ihex -R .eeprom "$ELF" "$HEX"

# Also produce a raw binary image (compact, no Intel HEX overhead)
BIN="${BASE}.bin"
avr-objcopy -O binary -R .eeprom "$ELF" "$BIN"

echo "Built: $HEX and $BIN"
