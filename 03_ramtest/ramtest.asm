	ORG	0x0000

	PIOAD:	EQU 0x04 ; pio port A data
	PIOBD:	EQU 0x05 ; pio port B data
	PIOAC:	EQU 0x06 ; pio port A control
	PIOBC:	EQU 0x07 ; pio port B control

	; pause
	LD	D, 0xb0
loop1:
	LD	B, 0xff
loop2:
	DJNZ	loop2
	DEC	D
	JP	NZ, loop1

	; init pio
	LD	A, 0xcf ; bit mode (mode 3)
	OUT	(PIOAC), A
	LD	A, 0x00 ; all ports are output
	OUT	(PIOAC), A
	LD	A, 0xff ; bitpattern (all on)
	OUT	(PIOAD), A
	
	; pause
	LD	D, 0xb0
loop3:
	LD	B, 0xff
loop4:
	DJNZ	loop4
	DEC	D
	JP	NZ, loop3

	; pio output
	LD	A, 0x00 ; bitpattern (all off)
	OUT	(PIOAD), A

	; pause
	LD	D, 0xb0
loop5:
	LD	B, 0xff
loop6:
	DJNZ	loop6
	DEC	D
	JP	NZ, loop5

	; pio output
	LD	A, 0xff ; bitpattern (all on)
	OUT	(PIOAD), A

	; store bit pattern in ram at 0x8000 (beginning of ram)
	LD	A, 10101010b
	LD	(0x8000), A
	; set A register to 0
	LD	A, 0
	; load bit pattern from ram
	LD	A, (0x8000)
	; output bitpattern read from memory
	OUT	(PIOAD), A

	; pause
	LD	D, 0xb0
loop7:
	LD	B, 0xff
loop8:
	DJNZ	loop8
	DEC	D
	JP	NZ, loop7

	HALT

