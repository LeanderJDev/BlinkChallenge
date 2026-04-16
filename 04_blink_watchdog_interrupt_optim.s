#include <avr/io.h>

#define _IO _SFR_IO_ADDR

#define _MEM _SFR_MEM_ADDR

; Programmstart / Initialisierung
start:
	; set WDT change enable (WDCE) + WDE as required by sequence
	ldi r16, (1<<WDCE)|(1<<WDE)   ; WDCE=1, WDE=1
	sts _MEM(WDTCSR), r16
	; innerhalb von 4 Taktzyklen neuen WDTCSR schreiben: WDIE + Prescaler (~1s)
	ldi r16, (1<<WDIE)|(1<<WDP2)|(1<<WDP1)  ; WDIE=1, WDP2:WDP1 => 0b0110 => ~1s
	sts _MEM(WDTCSR), r16
	sei
interrupt:
	; Toggle PB5 über PIN register
	sbi _IO(PINB), 5
main:
	rjmp main ; Endlosschleife