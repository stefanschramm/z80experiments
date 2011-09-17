	ORG	0x0000

	LD	D, 0xb0
loop1:	LD	B, 0xff
loop2:	DJNZ	loop2
	DEC	D
	JP	NZ, loop1

	HALT
