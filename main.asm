#include "defs.asm"

        .word progstart         ; Starting address for PRG file
        * = progstart
        .word nextln            ; Next-line pointer
        .word 0                 ; Line number
        .byt $9e,"2061",0       ; SYS 2061
nextln  .word 0                 ; End of program marker

#include "mkexplog.asm"
#include "mkdatastream.asm"
#include "mkgen.asm"
#include "calcecc.asm"
#include "interleave.asm"
#include "mkmatrix.asm"
#include "display.asm"

        rts                     ; Return to BASIC

#include "subroutines.asm"
#include "data.asm"
