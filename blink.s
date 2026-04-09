; Minimal blink with only required setup + line-by-line comments
; Define required I/O register and bit constants so assembler accepts sbi/cbi
.equ DDRB, 0x04
.equ PORTB, 0x05
.equ PB5, 5

.global main

main:
    ; Set data direction: make PB5 an output (DDRB bit 5 = 1)
    sbi DDRB, PB5        ; DDRB |= (1<<PB5)
    ; Drive the output high to switch LED on
    sbi PORTB, PB5       ; PORTB |= (1<<PB5)
    ; Call blocking delay subroutine (push return addr)
    rcall delay              ; call delay()
    ; Drive the output low to switch LED off
    cbi PORTB, PB5       ; PORTB &= ~(1<<PB5)
    ; Call blocking delay again
    rcall delay              ; call delay()
    ; Jump back to start of main loop (infinite loop)
    rjmp main                ; goto main

delay:
    ; Outer loop counter (high level)
    ldi  r18, 82        ; r18 = 82 (outer loop)
    ; Inner loop counter (middle level)
    ldi  r19, 43        ; r19 = 43 (middle loop)
    ; Innermost counter initialized to 0 so dec -> 0xFF (256 iterations)
    ldi  r20, 0         ; r20 = 0 (innermost loop)
L1: dec  r20            ; decrement innermost counter
    brne L1             ; if r20 != 0 continue inner loop
    dec  r19            ; after inner loop, decrement middle counter
    brne L1             ; if r19 != 0 repeat inner loop
    dec  r18            ; after middle loop, decrement outer counter
    brne L1             ; if r18 != 0 repeat all loops
    ; small padding instructions to adjust timing precisely
    lpm                 ; load from program memory (used as timing filler)
    nop                 ; one-cycle no-op (timing)
    ret                 ; return to caller (rcall restores return address)