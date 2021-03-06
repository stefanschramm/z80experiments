z80experiments
==============

This is the documentation of my experiments with a Z80 CPU and related components.

I did the experiments in the order as they are numbered. From experiment 01 on the system is extended step by step in a way that the old software in the ROM from the previous experiment should be able to work with the new wiring. I highly recommend to test if the old software still works after re-wiring because it might help to find some gross errors.

00 minimal test
---------------

Components:
* 1 x Breadboard :)
* 1 x 5 V power supply (I currently use an old AT power supply from a 486; the allocation of the peripheral connector is: black = GND, red = +5 V)
* 1 x Z80 CPU (DIL package)
* 3 x 5 V LED (these LEDs include an resistor for direct usage with 5 V)
* 1 x 1 MHz oscillator
* 8 x  2,2 K resistors
* some cables

The LEDs are connected to the 3 most significant bits of the address bus. The data bus lines are connected to GND using the resistors. They produce the bit pattern 00000000 which is the NOP command. When powered on the LEDs should light up alternately (counting up) because the CPU walks thru the complete address space executing NOPs.

01 looptest
-----------

Additional components:
* 1 x EEPROM 28C64
* (EEPROM programmer, z80asm)

The 64 kBit (= 8 kByte) EEPROM is connected in a way that it's mapped to the 0x0000 - 0x2000 address space. When the CPU starts/resets it will execute the commands from 0x0000 on. The programm in the EEPROM loops a bit and then HALTs the CPU which should lit the LED connected to the HALT output.

02 piotest
----------

Additional components:
* 1 x Z80 PIO

The Z80 PIO is connected to the CPU and is addressed by the IO adresses 0x04 to 0x07. The program sets port A into bit mode and declares all 8 pins as output. After initialization the LEDs connected to PIO port A are switched on, off and on again. This system still works without RAM.

03 ramtest
----------

Additional components:
* 1 x SRAM 62256

The RAM is mapped to 0x8000 to 0xffff (the complete second half of the address space). The program is the same as before, but in the last step it writes the bit pattern 10101010 into memory location 0x8000, sets the A register to 0, does a pause, reads the bit pattern from 0x8000 and outputs it to the LEDs. So if the RAM is working correctly the LEDs should show the pattern 10101010.

04 stacktest
------------

Since the system has got some RAM, now a stack can be used (which is needed for operations like PUSH, POP, CALL and RET - especially to do function calls). At first the stackpointer (SP) is initialized with 0xffff because it grows downwards. The program parts for the pauses are outsourced and called as function (pause). This way the program got a bit shorter (not just the asm source code, but also the assembled binary).
When using functions it is important to pay attention which registers are modified by the function. In the pause function the D and B registers are modified but the others like A are preserved.

05 uartblink
------------

Additional components:
* 1 x UART 16C550

The program reads the UART MCR (modem control register), toggles bit 2 and 3 (UART outputs OUT1 and OUT2) and writes the result back into the MCR. This process is looped and should make the LEDs connected to the UART blink. In this case no special initialization of the UART is required.

06 uartoutput
-------------

Additional components:
* 1 x MAX232N

The UART is initialized (baudrate of 9600 bps) and then outputs the character 'X' in a loop. This and the following experiments can be tested using any terminal emulator. I prefer microcom, but others like minicom or HyperTerminal should work as well. The settings are speed: 9600 baud, flow control: none, 8 data bits, no parity, 1 stopbit ("8N1").

07 uartinputoutput
------------------

In a loop a character is read from the UART's serial input, outputs the bitpattern to the PIO's LEDs and sends it back to serial output ("echo").

08 uartloader
-------------

The loader implements two commands that can be sent via serial interface: 'L' for "load" and 'J' for "jump". The load command is used to read arbitrary data and store it into the RAM. It expects two two-byte (16 bit) arguments: the length of the data to store and the memory location where the data should be stored. These values are expected in little-endian encoding which means that the lower 8 bits of the number need to be sent first.
If the serial interface of the computer connected to the system's UART is already configured correctly (9600 bps) you could simply use echo to load some data:
echo -e -n "L\x09\x00\x00\x80ABCDEFGHI" > /dev/ttyS0
Will load 9 bytes ("ABCDEFGHI") into memory location 0x8000.
The jump command expects as argument the memory location where to jump to. Load and jump can be used to load and execute code without re-flashing the EEPROM all the time.
The Python scripts load.py and jump.py can be used to load and execute code. loadable.asm contains an example which can be assembled and loaded at 0x8000. For loadable programs it's important to correctly specify ORG that the assembler will put in the right values for absolute memory adresses.

