	ORG	0x0000

	PIOAD:	EQU 0x04
	PIOBD:	EQU 0x05
	PIOAC:	EQU 0x06
	PIOBC:	EQU 0x07

	RAMEND:	EQU 0xffff
	RAMBEG:	EQU 0x8000

	PAUSEDURATION:	EQU 0x8100
	LEDPATTERN:	EQU 0x8101

main:
	; init stack to end of ram
	LD	SP, RAMEND

	; init pio
	LD	A, 0xcf ; bit mode (mode 3)
	OUT	(PIOAC), A
	LD	A, 0x00 ; all ports are output
	OUT	(PIOAC), A

	; init ram variables
	LD	A, 0xb0
	LD	(PAUSEDURATION), A
	LD	A, 1
	LD	(LEDPATTERN), A

mainloop:
	; change led status
	LD	A, (LEDPATTERN)
	RLCA
	LD	(LEDPATTERN), A
	CALL	ledoutput
	; load b, get faster
	LD	A, (PAUSEDURATION)
	SUB	1
	LD	(PAUSEDURATION), A
	LD	D, A
	; do pause
	CALL	pause
	; repeat
	JP	mainloop

	HALT

; pause
; reads: D (pause)
; destroys: D, B
pause:
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

