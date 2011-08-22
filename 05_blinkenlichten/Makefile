
# required packages for building:
# - geda-gschem (gschem)
# - texlive-latex-extra  (ps2pdf)
# - imagemagick (convert)
# - z80asm (z80asm)

all:	05_schematics.pdf 05_blinkenlichten.bin 05_schematics.png

%.ps:	%.sch
	gschem -q -o$@ -s/usr/share/gEDA/scheme/print.scm $<

%.pdf:	%.ps
	ps2pdf $< $@

%.png:	%.ps
	convert -density 300x300 -scale 1600x -alpha off -rotate 90 $< $@

%.bin:	%.asm
	z80asm	$< -o $@
	
clean:
	rm -f *.ps
	rm -f *.pdf
	rm -f *.png
	rm -f *.bin
