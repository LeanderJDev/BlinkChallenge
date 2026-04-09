#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <file.elf|file.o> [out.asm]"
  exit 1
fi

SRC="$1"
OUT="${2:-${SRC%.*}.asm}"

if [[ ! -f "$SRC" ]]; then
  echo "Error: file not found: $SRC"
  exit 1
fi

case "$SRC" in
  *.elf|*.o)
    echo "Disassembling $SRC -> $OUT"
    avr-objdump -d -S "$SRC" > "$OUT"
    ;;
  *.hex|*.bin)
    echo "Error: please provide an ELF (.elf) or object (.o) file produced by avr-gcc/build.sh"
    echo "If you only have an Intel HEX, convert it first, e.g.:"
    echo "  avr-objcopy -I ihex -O elf32-avr input.hex temp.elf"
    exit 2
    ;;
  *)
    echo "Unsupported file type. Provide an ELF (.elf) or object (.o) file."
    exit 3
    ;;
esac

echo "Wrote: $OUT"
