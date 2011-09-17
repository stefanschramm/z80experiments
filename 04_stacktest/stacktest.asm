	ORG	0x0000

	PIOAD:	EQU 0x04
	PIOBD:	EQU 0x05
	PIOAC:	EQU 0x06
	PIOBC:	EQU 0x07

	RAMBEG:	EQU 0x8000
	RAMEND:	EQU 0xffff

main:
	; init stackpointer to end of ram
	LD	SP, RAMEND

	; init pio
	LD	A, 0xcf ; bit mode (mode 3)
	OUT	(PIOAC), A
	LD	A, 0x00 ; all ports are output
	OUT	(PIOAC), A

	LD	A, 11000000b
	OUT	(PIOAD), A
	CALL	pause
	RRA
	OUT	(PIOAD), A
	CALL	pause
	RRA
	OUT	(PIOAD), A
	CALL	pause
	RRA
	OUT	(PIOAD), A
	CALL	pause
	RRA
	OUT	(PIOAD), A
	CALL	pause
	RRA
	OUT	(PIOAD), A
	CALL	pause
	RRA
	OUT	(PIOAD), A
	CALL	pause

	HALT

; pause (function)
; destroys: D, B
pause:
	LD	D, 0xb0
loop1:
	LD	B, 0xff
loop2:
	DJNZ	loop2
	DEC	D
	JP	NZ, loop1
	RET

