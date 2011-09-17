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

mainloop:

	; pio led 1 on (waiting for command)
	LD	A, 00000001b
	OUT   (PIOAD), A

	; wait for command
	CALL	getc
	; register A contains read character
	CP	'L'
	CALL	Z, command_load
	CP	'J'
	CALL	Z, command_jump

	; CALL	putc

	; repeat
	JP	mainloop

	HALT

command_load:
	; store registers
	PUSH	AF
	PUSH	BC
	PUSH	HL
	; show status on pio leds
	LD	A, 00000010b
	OUT   (PIOAD), A
	; read filesize
	CALL	getc
	LD	C, A
	CALL	getc
	LD	B, A
	; show status on pio leds
	LD	A, 00000100b
	OUT   (PIOAD), A
	; read memory target address
	CALL	getc
	LD	L, A
	CALL	getc
	LD	H, A
	; show status on pio leds
	LD	A, 00001000b
	OUT   (PIOAD), A
	; read data loop
command_load_loop:

	; display c ("bytes left")
	LD	A, C
	OUT   (PIOAD), A

	CALL	getc
	; store read byte into memory
	LD	(HL), A
	INC	HL
	DEC	BC
	LD	A, 0
	CP	B
	JP	NZ, command_load_loop
	CP	C
	JP	NZ, command_load_loop
	; B and C are zero - continue

	; show status on pio leds
	LD	A, 00010000b
	OUT   (PIOAD), A

	; restore registers and return
	POP	HL
	POP	BC
	POP	AF
	RET

command_jump:
	PUSH	HL
	; read memory target address to jump to
	CALL	getc
	LD	L, A
	CALL	getc
	LD	H, A
	; do jump
	; TODO: try to simulate a CALL here?; put current address to stack?
	JP	(HL)
	POP	HL
	RET

; pause
; reads: D (pause)
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

