
blink_watchdog_interrupt_optim_2.elf:     Dateiformat elf32-avr


Disassembly of section .text:

00000000 <__ctors_end>:
   0:	0e e5       	ldi	r16, 0x5E	; 94
   2:	00 93 60 00 	sts	0x0060, r16	; 0x800060 <__DATA_REGION_ORIGIN__>
   6:	00 93 60 00 	sts	0x0060, r16	; 0x800060 <__DATA_REGION_ORIGIN__>
   a:	78 94       	sei

0000000c <interrupt>:
   c:	1d 9a       	sbi	0x03, 5	; 3

0000000e <main>:
   e:	ff cf       	rjmp	.-2      	; 0xe <main>
