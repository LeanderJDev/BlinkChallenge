#include <avr/io.h>

#define _IO _SFR_IO_ADDR

#define _MEM _SFR_MEM_ADDR

; Vektor‑Tabelle: RESET + Füllvektoren bis WDT (Vector index für WDT = 6)
.org 0
rjmp reset       ; 0 - RESET
rjmp reset       ; 1
rjmp reset       ; 2
rjmp reset       ; 3
rjmp reset       ; 4
rjmp reset       ; 5
rjmp interrupt   ; 6 - WDT_vect -> springe auf `interrupt`

; Reset-Handler springt in die Initialisierung
reset:
	rjmp start

; Programmstart / Initialisierung
start:
	cli
	; set WDT change enable (WDCE) + WDE as required by sequence
	ldi r16, (1<<WDCE)|(1<<WDE)   ; WDCE=1, WDIE=1, WDE=0 (interrupt only mode)
	sts _MEM(WDTCSR), r16
	; innerhalb von 4 Taktzyklen neuen WDTCSR schreiben: WDIE + Prescaler (~1s)
	ldi r16, (1<<WDIE)|(1<<WDP2)|(1<<WDP1)  ; WDIE=1, WDP2:WDP1 => 0b0110 => ~1s
	sts _MEM(WDTCSR), r16
	; Setze PB5 als Ausgang
	sbi _IO(DDRB), 5
	sei
interrupt:
	; Toggle PB5 über PIN register
	sbi _IO(PINB), 5
main:
	rjmp main ; Endlosschleife
; WDT ISR: wird bei Watchdog-Interrupt aufgerufen