#include <avr/io.h>

#define _IO _SFR_IO_ADDR

#define _MEM _SFR_MEM_ADDR

; Programmstart / Initialisierung
start:
	ldi r16, (1<<WDCE)|(1<<WDE)|(1<<WDIE)|(1<<WDP2)|(1<<WDP1) ; Watchdog-Interrupt alle 1s, Interrupt aktiviert
	sts _MEM(WDTCSR), r16 ; Schreiben um WDTCSR ändern zukönnen (siehe Handbook)
	sts _MEM(WDTCSR), r16 ; Dann tatsächliche Daten schreiben
	sei ; Interrupts global aktivieren
interrupt:
	; Toggle PB5 über PIN register
	sbi _IO(PINB), 5
main:
	rjmp main ; Endlosschleife damit der Watchdog-Interrupt ausgelöst wird