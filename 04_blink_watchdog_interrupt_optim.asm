
blink_watchdog_interrupt_optim.elf:     Dateiformat elf32-avr


Disassembly of section .text:

00000000 <__ctors_end>:
   0:	08 e1       	ldi	r16, 0x18	; 24
   2:	00 93 60 00 	sts	0x0060, r16	; 0x800060 <__DATA_REGION_ORIGIN__>
   6:	06 e4       	ldi	r16, 0x46	; 70
   8:	00 93 60 00 	sts	0x0060, r16	; 0x800060 <__DATA_REGION_ORIGIN__>
   c:	78 94       	sei

0000000e <interrupt>:
   e:	1d 9a       	sbi	0x03, 5	; 3

00000010 <main>:
  10:	ff cf       	rjmp	.-2      	; 0x10 <main>
