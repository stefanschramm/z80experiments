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

	RAMBEG:	EQU 0x8000
	RAMEND:	EQU 0xffff

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

	; disable all interrupts
	LD	A, 0x00 
	; send to Interrupt Enable Register
	OUT	(UART_IER), A 
	; mask to set DLAB on
	LD	A, 0x80
	; send to Line Control Register
	OUT	(UART_LCR), A 
	; divisor of 12 = 9600 bps with 1.8432 MHz clock (1843200 Hz / 16 / 12 = 9600 bps)
	LD	A, 12 
	; set LSB of divisor 
	OUT	(UART_THR), A        
	; this will be the MSB of the divisior
	LD	A, 00            
	; send to the MSB register
	OUT	(UART_IER), A        
	; 8 bits, 1 stop, no parity (and clear DLAB)
	LD	A, 0x03          
	; write new value to LCR
	OUT	(UART_LCR), A     

	; pio led on
	LD	A, 00000001b
	OUT   (PIOAD), A

	LD	D, 0xb0
	CALL	pause

mainloop:

	CALL	getc

	OUT	(PIOAD), A

	CALL	putc

	; repeat
	JP	mainloop

	HALT

; pause
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
	RET

; getc
; returns: A (received character)
getc:
	; wait for uart
	IN	A, (UART_LSR)
	BIT	0, A
	JR	Z, getc
	IN	A, (UART_RBR)
	RET

