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
	LD	B, 0x03
loop2:
	DJNZ	loop2
	POP	BC
	RET
