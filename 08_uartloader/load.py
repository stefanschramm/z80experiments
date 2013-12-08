#!/usr/bin/python

import sys
import os
import struct

if len(sys.argv) != 2:
	print "Usage: " + sys.argv[0] + " filename"
	sys.exit(1)

filename = sys.argv[1]
filesize = os.stat(filename).st_size

#tty = open("/dev/ttyS0", "w")
tty = open("/dev/ttyUSB0", "w")
f = open(filename)

# call 'load' command
tty.write("L")
# write file size (as little endian unsigned short == 2 bytes)
tty.write(struct.pack("<H", filesize))
# write memory target address (begin of memory)
tty.write(struct.pack("<H", 0x8000))
# send file data
tty.write(f.read(filesize))

f.close
tty.close
