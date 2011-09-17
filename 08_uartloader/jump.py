#!/usr/bin/python

import struct

tty = open("/dev/ttyS0", "w")

# call 'jump' command
tty.write("J")
# write memory address to exec (begin of memory)
tty.write(struct.pack("<H", 0x8000))

tty.close
