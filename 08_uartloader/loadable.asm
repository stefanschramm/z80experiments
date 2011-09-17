	ORG	0x8000

	PIOAD:	EQU 0x04

	LD	A, 00000001b
loop:
	RLCA
	OUT	(PIOAD), A
	CALL	pause
	JP	loop


pause:
	PUSH	BC
	LD	C, 0x10
loop1:
	LD	B, 0xff
loop2:
	DJNZ	loop2
	DEC	C
	JP	NZ, loop1
	POP	BC
	RET
