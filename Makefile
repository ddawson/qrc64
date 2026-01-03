files := calcecc.asm data.asm defs.asm display.asm interleave.asm main.asm \
         mkdatastream.asm mkexplog.asm mkgen.asm mkmatrix.asm subroutines.asm

qrc64.d64: qrc64.prg
ifeq ($(shell ls $@),$@)
	c1541 $@ -del qrc64 -write qrc64.prg qrc64
else
	c1541 -format qrc64,qr d64 $@ -write qrc64.prg qrc64
endif

qrc64.prg: $(files)
	xa -v -W -XMASM -a -O PETSCII -c -l $(basename $@).lst -o $@ main.asm
