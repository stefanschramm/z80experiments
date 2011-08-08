	ORG	0x0000

	PIOAD:	EQU 0x04
	PIOBD:	EQU 0x05
	PIOAC:	EQU 0x06
	PIOBC:	EQU 0x07

	RAMEND:	EQU 0xffff
	RAMBEG:	EQU 0x8000

main:
	; init stack to end of ram
	LD	SP, RAMEND

	; init pio
	LD	A, 0xcf ; bit mode (mode 3)
	OUT	(PIOAC), A
	LD	A, 0x00 ; all ports are output
	OUT	(PIOAC), A

	LD	A, 0x00
	CALL	ledoutput
	LD	A, 11000000b
	CALL	ledoutput
	CALL	pause
	RRA
	CALL	ledoutput
	CALL	pause
	RRA
	CALL	ledoutput
	CALL	pause
	RRA
	CALL	ledoutput
	CALL	pause
	RRA
	CALL	ledoutput
	CALL	pause

	HALT

; pause
; destroys: D, B
pause:
	LD	D, 0xb0
loop1:	LD	B, 0xff
loop2:	DJNZ	loop2
	DEC	D
	JP	NZ, loop1
	RET

; ledoutput
; reads: A (led bitpattern)
ledoutput:
	OUT	(PIOAD), A
	RET

