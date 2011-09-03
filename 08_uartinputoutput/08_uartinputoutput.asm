	ORG	0x0000

	PIOAD:	EQU 0x04
	PIOBD:	EQU 0x05
	PIOAC:	EQU 0x06
	PIOBC:	EQU 0x07

	UART_BASE:	EQU 0x10
	UART_RBR:	EQU UART_BASE + 0x00
	UART_THR:	EQU UART_BASE + 0x00
	UART_IER:	EQU UART_BASE + 0x01
	UART_IIR:	EQU UART_BASE + 0x02
	UART_FCR:	EQU UART_BASE + 0x02
	UART_LCR:	EQU UART_BASE + 0x03
	UART_MCR:	EQU UART_BASE + 0x04
	UART_LSR:	EQU UART_BASE + 0x05
	UART_MSR:	EQU UART_BASE + 0x06
	UART_SCR:	EQU UART_BASE + 0x07
	; when DLAB = 1:
	UART_DLL:	EQU UART_BASE + 0x00
	UART_DLM:	EQU UART_BASE + 0x01

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

	; init uart (0x10 - 0x17)
	; taken from http://www.cosam.org/projects/z80/serial.html
	LD	A, 0x00          ; Disable all interrupts
	OUT	(UART_IER), A    ; Send to Interrupt Enable Register
	LD	A, 0x80          ; Mask to set DLAB on
	OUT	(UART_LCR), A    ; Send to Line Control Register
	LD	A, 12            ; Divisor of 12 = 9600 bps with 1.8432 MHz clock
		                 ; (1843200 Hz / 16 / 12 = 9600 bps)
	OUT	(UART_THR), A    ; Set LSB of divisor
	LD	A, 00            ; This will be the MSB of the divisior
	OUT	(UART_IER), A    ; Send to the MSB register
	LD	A, 0x03          ; 8 bits, 1 stop, no parity (and clear DLAB)
	OUT	(UART_LCR), A    ; Write new value to LCR

	; pio led on
	LD	A, 00000001b
	OUT   (PIOAD), A

	LD	D, 0xb0
	CALL	pause

mainloop:

	CALL	getc

	OUT	(PIOAD), A

	; CALL	putc
	; TODO: problem hier: data ready status wird beim schreiben geaendert --> getc liest nur noch jedes 2te byte

	; repeat
	JP	mainloop

	HALT

; pause
; reads: D (pause)
; destroys: D, B
pause:
	PUSH	DE
	PUSH	BC
loop1:
	LD	B, 0xff
loop2:
	DJNZ	loop2
	DEC	D
	JP	NZ, loop1
	POP	BC
	POP	DE
	RET

; putc
; reads: A (character to send to uart)
putc:
	PUSH	AF
uartloop:
	; wait for uart
	IN	A, (UART_LSR)
	BIT	5, A
	JP	Z, uartloop
	POP	AF
	OUT	(UART_THR), A

; getc
; returns: A (received character)
getc:
	; wait for uart
	IN	A, (UART_LSR)
	BIT	0, A
	JR	Z, getc
	IN	A, (UART_RBR)
	RET

