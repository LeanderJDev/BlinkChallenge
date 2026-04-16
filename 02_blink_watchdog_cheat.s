#include <avr/io.h>

#define _IO _SFR_IO_ADDR

#define _MEM _SFR_MEM_ADDR

main:
	; set WDT to interrupt+reset or reset only as needed; here: enable reset + 1s timeout
	ldi r16, (1<<WDCE)|(1<<WDE)   ; Set Watchdog Change Enable + Watchdog Enable
	sts _MEM(WDTCSR), r16
    ; within 4 cycles write new WDTCSR value:
	ldi r16, (1<<WDE)|(1<<WDP2)|(1<<WDP1)  ; WDE=1, WDP2:WDP1 => 0b0110 => ~1s
	sts _MEM(WDTCSR), r16
	sbi _IO(DDRB), 5 ; Set pin 13 (PB5) as output
	; This let's the LED blink for a short moment because it is on when reset and turns off when setting DDRB
loop:
	rjmp loop ; Infinite loop to get the watchdog timer to reset the microcontroller