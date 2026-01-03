        tmp1 = 2
        tmp2 = 3
        tmp3 = 4
        tmp4 = 5
        tmp5 = 6
        tmp6 = $2a
        tmp7 = $52
        tmp8 = $fb
        tmp9 = $fc
        tmp10 = $fd
        chrin = $ffcf
        chrout = $ffd2
        getin = $ffe4
        progstart = $0801
        maxinp = 79             ; Max length of user input
        binmode = 4             ; Mode indicator for binary
        filler1 = $ec
        filler2 = $11
        ecmaxsize = 28          ; Max size of ECC part of a block
        blkmaxsize = 134        ; Max size of an ECC block
        totalmaxsize = 172      ; Max size of all data and ECC together
        prim = $1d              ; Actually $11d, but high bit is implied
        matrixsize = 6*42
        bchgen = $537           ; BCH generator (for format string)
        fmtinfomask = $a824     ; XOR mask applied to format string
        scrmem = $400
        memsetup = $d018        ; Checked to determine active charset
        borderclr = $d020
        bgclr = $d021

#define PRINT(addr) \
        .( :\
        ldy #0 :\
ploop   lda addr,y :\
        beq done :\
        jsr chrout :\
        iny :\
        bne ploop :\
done    .)

#define SETPTR(base, offset, putat) \
        lda #<base :\
        clc :\
        adc offset :\
        sta putat :\
        lda #>base :\
        adc #0 :\
        sta putat + 1

#define SETPTR_OFFSET_X(base, offs_ary, putat) \
        lda #<base :\
        clc :\
        adc offs_ary,x :\
        sta putat :\
        lda #>base :\
        adc #0 :\
        sta putat + 1

#define ADDPTR(val, putat) \
        lda putat :\
        clc :\
        adc val :\
        sta putat :\
        lda putat + 1 :\
        adc #0 :\
        sta putat + 1
