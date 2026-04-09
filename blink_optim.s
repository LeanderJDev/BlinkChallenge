; Minimal blink with only required setup + line-by-line comments
; Define required I/O register and bit constants so assembler accepts sbi/cbi
.equ PINB, 0x03
.equ DDRB, 0x04
.equ PORTB, 0x05
.equ PB5, 5

.global main

main:
    ; Configure PB5 as output (set DDRB bit 5)
    sbi DDRB, PB5        ; DDRB |= (1<<PB5)
    ; Toggle the pin by writing a 1 to PINB bit 5 (hardware toggles output)
    sbi PINB, PB5        ; PINB |= (1<<PB5)  (toggle PB5)
    ; Call blocking delay routine
    rcall delay              ; call delay()
    ; Loop forever
    rjmp main                ; goto main

delay:
    ; Outer loop counter
    ldi  r18, 82        ; r18 = 82 (outer loop)
    ; Middle loop counter
    ldi  r19, 43        ; r19 = 43 (middle loop)
    ; Innermost counter starts at 0 so dec -> 0xFF (256 iterations)
    ldi  r20, 0         ; r20 = 0 (innermost loop)
L1: dec  r20            ; decrement innermost counter
    brne L1             ; repeat inner loop while r20 != 0
    dec  r19            ; decrement middle counter
    brne L1             ; repeat middle/inner loops while r19 != 0
    dec  r18            ; decrement outer counter
    brne L1             ; repeat all loops while r18 != 0
    lpm                 ; timing filler (read from flash)
    nop                 ; one-cycle delay
    ret                 ; return to caller