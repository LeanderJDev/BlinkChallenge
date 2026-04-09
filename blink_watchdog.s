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
	sbi _IO(PINB), 5 ; Toggle pin 13 (PB5)
	sbi _IO(PINB), 5 ; Toggle pin 13 (PB5)
loop:
	rjmp loop ; Infinite loop to keep the program running