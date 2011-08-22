	ORG	0x0000

	PIOAD:	EQU 0x04
	PIOBD:	EQU 0x05
	PIOAC:	EQU 0x06
	PIOBC:	EQU 0x07

; pause 
	LD	D, 0xb0
loop1:	LD	B, 0xff
loop2:	DJNZ	loop2
	DEC	D
	JP	NZ, loop1

; init pio
	LD	A, 0xcf ; bit mode (mode 3)
	OUT	(PIOAC), A
	LD	A, 0x00 ; all ports are output
	OUT	(PIOAC), A
	LD	A, 0x00 ; bitpattern
	OUT	(PIOAD), A
	

; pause 
	LD	D, 0xb0
loop3:	LD	B, 0xff
loop4:	DJNZ	loop4
	DEC	D
	JP	NZ, loop3

; pio output
	LD	A, 00001010b ; bitpattern
	OUT	(PIOAD), A

; pause 
	LD	D, 0xb0
loop5:	LD	B, 0xff
loop6:	DJNZ	loop6
	DEC	D
	JP	NZ, loop5

; pio output
	LD	A, 00000101b ; bitpattern
	OUT	(PIOAD), A

; ram test (write)
	LD	A, 00000001b
	LD	(0xf000), A
	LD	A, 0

; pause 
	LD	D, 0xb0
loop7:	LD	B, 0xff
loop8:	DJNZ	loop8
	DEC	D
	JP	NZ, loop7

; ram test (read)
	LD	A, (0xf000)
; pio output
	OUT	(PIOAD), A

	HALT