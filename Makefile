
# required packages for building:
# - geda-gschem (gschem)
# - texlive-latex-extra  (ps2pdf)
# - imagemagick (convert)
# - z80asm (z80asm)

# z80 binaries
BIN = $(patsubst %.asm,%.bin,$(wildcard *.asm))

# schematics
PDF = $(patsubst %.sch,%.pdf,$(wildcard *.sch))
PNG = $(patsubst %.sch,%.png,$(wildcard *.sch))


all: $(BIN)

schematics: $(PDF) $(PNG)

%.ps: %.sch
	gschem -q -o$@ -s/usr/share/gEDA/scheme/print.scm $<

%.pdf: %.ps
	ps2pdf $< $@

%.png: %.ps
	convert -density 300x300 -scale 1600x -alpha off -rotate 90 $< $@

%.bin: %.asm
	z80asm $< -o $@
	
clean:
	rm -f *.ps *.pdf *.png *.bin

