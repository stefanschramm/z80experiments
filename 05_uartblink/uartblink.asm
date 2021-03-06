	ORG	0x0000

	PIOAD:	EQU 0x04
	PIOBD:	EQU 0x05
	PIOAC:	EQU 0x06
	PIOBC:	EQU 0x07
	
	; uart base address: 0x10, offset for MCR: 0x04
	UART_BASE:	EQU 0x10
	UART_MCR:	EQU UART_BASE + 0x04

	RAMBEG:	EQU 0x8000
	RAMEND:	EQU 0xffff

main:
	; init stack to end of ram
	LD	SP, RAMEND

	CALL	pause

	; init pio
	LD	A, 0xcf ; bit mode (mode 3)
	OUT	(PIOAC), A
	LD	A, 0x00 ; all ports are output
	OUT	(PIOAC), A

mainloop:

	; pio a led on
	LD	A, 00000001b
	OUT	(PIOAD), A

	; read uart's mcr
	IN	A, (UART_MCR)
	; toggle out1 and out2
	XOR	00001100b
	; write back
	OUT	(UART_MCR), A

	CALL	pause

	; pio a leds off
	LD	A, 00000000b
	OUT	(PIOAD), A

	CALL	pause

	; repeat
	JP	mainloop

	; never reached
	HALT

; pause
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

