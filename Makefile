# Makefile: Reimplements the repo's shell scripts as Make targets
# Usage examples:
#   make build SRC=blink.s        # build into $(BUILD_DIR)
#   make disassemble SRC=file.elf OUT=out.asm
#   make flash SRC=blink.s        # or make flash HEX=build/blink.hex
#   make fuse                      # interactive fuse writer
#   make install                   # install system deps (uses sudo)

BUILD_DIR ?= build
MCU ?= atmega328p
F_CPU ?= 16000000UL
PROGRAMMER ?= arduino
BAUD ?= 115200
PORT ?=

LFUSE ?= 0xFF
HFUSE ?= 0xDE
EFUSE ?= 0x05

.PHONY: all build disassemble flash fuse install clean

# Allow calling like: `make build blink` (second goal is the basename)
# NAME is taken from the second make goal. Silence unknown second goals
# so make doesn't try to build a file named by the basename.
NAME := $(word 2,$(MAKECMDGOALS))
%:: ;

all:
	@echo "Available targets: build disassemble flash fuse install clean"

build:
	# Usage: make build <basename>  (e.g. make build blink)
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make build <basename> (example: make build blink)"; exit 1; \
	fi; \
	SRC="$(NAME).s"; \
	BASE=$$(basename "$$SRC" .s); mkdir -p "$(BUILD_DIR)"; \
	OBJ="$(BUILD_DIR)/$${BASE}.o"; ELF="$(BUILD_DIR)/$${BASE}.elf"; HEX="$(BUILD_DIR)/$${BASE}.hex"; BIN="$(BUILD_DIR)/$${BASE}.bin"; \
	echo "Building $$SRC -> $$HEX (MCU=$(MCU), F_CPU=$(F_CPU))"; \
	avr-gcc -mmcu="$(MCU)" -DF_CPU="$(F_CPU)" -x assembler-with-cpp -c "$$SRC" -o "$$OBJ"; \
	avr-gcc -mmcu="$(MCU)" -nostartfiles "$$OBJ" -o "$$ELF"; \
	avr-objcopy -O ihex -R .eeprom "$$ELF" "$$HEX"; \
	avr-objcopy -O binary -R .eeprom "$$ELF" "$$BIN"; \
	echo "Built: $$HEX and $$BIN"

disassemble:
	# Usage: make disassemble <basename>  (e.g. make disassemble blink)
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make disassemble <basename> (example: make disassemble blink)"; exit 1; \
	fi; \
	SRC="$(BUILD_DIR)/$(NAME).elf"; \
	OUT=${OUT:-$$(basename "$$SRC" | sed 's/\.[^.]*$$/.asm/')} ; \
	echo "Disassembling $$SRC -> $$OUT"; \
	avr-objdump -d -S "$$SRC" > "$$OUT"; \
	echo "Wrote: $$OUT"

flash:
	# Usage: make flash <basename>  (e.g. make flash blink_optim)
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make flash <basename> (example: make flash blink_optim)"; exit 1; \
	fi; \
	HEX_SHELL="$(BUILD_DIR)/$(NAME).hex"; \
	echo HEX_SHELL="$$HEX_SHELL"; \
	# detect port if not provided \
	if [ -z "$(PORT)" ]; then \
		for p in /dev/ttyACM0 /dev/ttyACM1 /dev/ttyUSB0 /dev/ttyUSB1; do \
			[ -e "$${p}" ] && PORT_SHELL="$${p}" && break; \
		done; \
	else \
		PORT_SHELL="$(PORT)"; \
	fi; \
	if [ -z "$$PORT_SHELL" ]; then \
		echo "Error: no serial port found. Set PORT=/dev/ttyACM0, or pass it as argument."; exit 1; \
	fi; \
	avrdude -v -p "$(MCU)" -c "$(PROGRAMMER)" -P "$$PORT_SHELL" -b "$(BAUD)" -D -U "flash:w:$$HEX_SHELL:i"; \
	echo "Flashed $$HEX_SHELL to $$PORT_SHELL"

fuse:
	@PORT_SHELL="${PORT:-/dev/ttyUSB0}"; PROGRAMMER_SHELL="${PROGRAMMER:-arduino}"; MCU_SHELL="${MCU:-m328p}"; BAUD_SHELL="${BAUD:-115200}"; DRYRUN=${DRYRUN:-false}; \
	echo "Target: MCU=$$MCU_SHELL, programmer=$$PROGRAMMER_SHELL, port=$$PORT_SHELL, baud=$$BAUD_SHELL"; \
	echo "Planned fuses:"; \
	echo "  LFUSE = $(LFUSE)"; echo "  HFUSE = $(HFUSE)"; echo "  EFUSE = $(EFUSE)"; \
	read -p "Type YES to continue and program these fuses: " CONFIRM; \
	if [ "$$CONFIRM" != "YES" ]; then echo "Aborted."; exit 1; fi; \
	if [ "$$DRYRUN" = "true" ]; then \
		echo "Dry run: would call avrdude to write fuses (not executing)."; \
		echo "avrdude -v -p $$MCU_SHELL -c $$PROGRAMMER_SHELL -P $$PORT_SHELL -b $$BAUD_SHELL -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m"; \
		exit 0; \
	fi; \
	avrdude -v -p "$$MCU_SHELL" -c "$$PROGRAMMER_SHELL" -P "$$PORT_SHELL" -b "$$BAUD_SHELL" \
		-U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m -U efuse:w:$(EFUSE):m; \
	echo "Done. Verify with: avrdude -p $$MCU_SHELL -c $$PROGRAMMER_SHELL -P $$PORT_SHELL -b $$BAUD_SHELL -v"

install:
	sudo apt update
	sudo apt install -y build-essential avrdude gcc-avr binutils-avr avr-libc avrdude avrdude-doc python3 python3-pip

clean:
	rm -rf $(BUILD_DIR)
	echo "Removed $(BUILD_DIR)"
