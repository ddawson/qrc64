        .(
        ;; Clear matrix and occupation flags
        lda #0
        ldx #0
loop    sta qmatrix,x
        sta moccupy,x
        inx
        cpx #matrixsize
        bne loop
        .)

        .(
        ;; Draw fixed patterns
        startcol = tmp3
        startrow = tmp4
        endcol = tmp5
        endrow = tmp6
        linecol = tmp3
        linerow = tmp3
        linestart = tmp4
        lineend = tmp5
        blkcol = tmp9
        blkrow = tmp10

        ;; Upper-left finder
        lda #0
        sta startcol
        sta startrow
        lda #8
        sta endcol
        sta endrow
        jsr clrrect
        lda #0
        sta blkcol
        sta blkrow
        jsr mkfindr

        ;; Lower-left finder
        lda nummod
        sta endrow
        sec
        sbc #8
        sta startrow
        lda #0
        sta startcol
        lda #8
        sta endcol
        jsr clrrect
        lda #0
        sta blkcol
        lda nummod
        sec
        sbc #7
        sta blkrow
        jsr mkfindr

        ;; Upper-right finder
        lda nummod
        sta endcol
        sec
        sbc #8
        sta startcol
        lda #0
        sta startrow
        lda #8
        sta endrow
        jsr clrrect
        lda #0
        sta blkrow
        lda nummod
        sec
        sbc #7
        sta blkcol
        jsr mkfindr

        ; Timing patterns
        lda #6
        sta linerow
        lda #8
        sta linestart
        lda nummod
        sec
        sbc #8
        sta lineend
        jsr althorz
        lda #6
        sta linecol
        lda #8
        sta linestart
        jsr altvert             ; lineend still has end pos.

        ;; Alignment pattern
        lda version
        cmp #1
        beq noalgn
        lda nummod
        sec
        sbc #9                  ; Left and top are 9 modules in.
        sta blkcol
        sta blkrow
        jsr mkalgn
noalgn  .)

        PRINT(drewfix)

#define BCHDIV(shift) \
        .( :\
        mask = $80 >> shift :\
        xorupper = bchgen >> (shift + 3) :\
        xorlower = (bchgen << (5 - shift))&$ff :\
        and #mask :\
        beq done :\
        txa :\
        eor #xorupper :\
        tax :\
        tya :\
        eor #xorlower :\
        tay :\
done    txa :\
        .)

setfinf .(
        ;; Set up format information
        lda eclevel
        asl                     ; Mask pattern 0
        asl
        asl
        asl                     ; Shift into position
        asl
        asl
        sta tmp1                ; Save for later
        tax
        ldy #0
        BCHDIV(0)
        BCHDIV(1)
        BCHDIV(2)
        BCHDIV(3)
        BCHDIV(4)
        ora tmp1                ; Put data back
        eor #>fmtinfomask
        sta fmtinf1
        tya
        eor #<fmtinfomask
        sta fmtinf2
        .)

#define PUTFMTBIT1(col1, row1, col2, row2) \
        .( :\
        asl fmtinf1 :\
        bcc clear :\
        lda col1 :\
        sta tmp1 :\
        lda row1 :\
        sta tmp2 :\
        jsr findbit :\
        jsr setbit :\
        lda col2 :\
        sta tmp1 :\
        lda row2 :\
        sta tmp2 :\
        jsr findbit :\
        jsr setbit :\
        jmp done :\
clear   lda col1 :\
        sta tmp1 :\
        lda row1 :\
        sta tmp2 :\
        jsr findbit :\
        jsr clrbit :\
        lda col2 :\
        sta tmp1 :\
        lda row2 :\
        sta tmp2 :\
        jsr findbit :\
        jsr clrbit :\
done    .)

#define PUTFMTBIT2(col1, row1, col2, row2) \
        .( :\
        asl fmtinf2 :\
        bcc clear :\
        lda col1 :\
        sta tmp1 :\
        lda row1 :\
        sta tmp2 :\
        jsr findbit :\
        jsr setbit :\
        lda col2 :\
        sta tmp1 :\
        lda row2 :\
        sta tmp2 :\
        jsr findbit :\
        jsr setbit :\
        jmp done :\
clear   lda col1 :\
        sta tmp1 :\
        lda row1 :\
        sta tmp2 :\
        jsr findbit :\
        jsr clrbit :\
        lda col2 :\
        sta tmp1 :\
        lda row2 :\
        sta tmp2 :\
        jsr findbit :\
        jsr clrbit :\
done    .)

        .(
        ;; Add format information
        pos = tmp3
        ldx nummod
        dex
        stx pos
        PUTFMTBIT1(#0, #8, #8, pos)
        dec pos
        PUTFMTBIT1(#1, #8, #8, pos)
        dec pos
        PUTFMTBIT1(#2, #8, #8, pos)
        dec pos
        PUTFMTBIT1(#3, #8, #8, pos)
        dec pos
        PUTFMTBIT1(#4, #8, #8, pos)
        dec pos
        PUTFMTBIT1(#5, #8, #8, pos)
        dec pos
        PUTFMTBIT1(#7, #8, #8, pos)
        dec pos
        lda #8                  ; Dark module
        sta tmp1
        lda pos
        sta tmp2
        jsr findbit
        jsr setbit
        PUTFMTBIT1(#8, #8, pos, #8)
        inc pos
        PUTFMTBIT2(#8, #7, pos, #8)
        inc pos
        PUTFMTBIT2(#8, #5, pos, #8)
        inc pos
        PUTFMTBIT2(#8, #4, pos, #8)
        inc pos
        PUTFMTBIT2(#8, #3, pos, #8)
        inc pos
        PUTFMTBIT2(#8, #2, pos, #8)
        inc pos
        PUTFMTBIT2(#8, #1, pos, #8)
        inc pos
        PUTFMTBIT2(#8, #0, pos, #8)
        .)

        PRINT(drewfmt)
        PRINT(drawdat)

        .(
        ;; Arrange data into matrix.
        nextbyte = tmp3
        curcol = tmp4
        currow = tmp5
        scandown = tmp6
        bitctr = tmp7
        curdata = tmp8
        curbit = tmp9
        lda #0
        sta nextbyte
        sta scandown
        ldx nummod
        dex
        stx curcol
        stx currow
        ldx #0
        stx bitctr
loop    bne bmore1
        ldx nextbyte
        lda intrlvd,x
        sta curdata
        inx
        stx nextbyte
        cpx intlvsz
        bne mordat1
        jmp done
mordat1 ldx #8
        stx bitctr
bmore1  lda curcol
        sta tmp1
        lda currow
        sta tmp2
        jsr findbit
        jsr chkbit
        bne part2
        asl curdata
        bcc zero1
        lda #1
        bne gotbit1
zero1   lda #0
gotbit1 sta curbit
        lda curcol
        eor currow              ; Mask pattern 0: (i+j)%2 == 0
        eor curbit              ; Apply to bit value
        and #1                  ; Only bit 0 matters
        bne clear1              ; Inverted
        jsr setbit              ; Offset and bit mask still in X and Y
        jmp nclear1
clear1  jsr clrbit
nclear1 dec bitctr
part2   dec curcol
        ldx bitctr
        bne bmore2
        ldx nextbyte
        lda intrlvd,x
        sta curdata
        inx
        stx nextbyte
        cpx intlvsz
        beq done
        ldx #8
        stx bitctr
bmore2  lda curcol
        sta tmp1
        lda currow
        sta tmp2
        jsr findbit
        jsr chkbit
        bne end2
        asl curdata
        bcc zero2
        lda #1
        bne gotbit2
zero2   lda #0
gotbit2 sta curbit
        lda curcol
        eor currow              ; Mask pattern 0: (i+j)%2 == 0
        eor curbit              ; Apply to bit value
        and #1                  ; Only bit 0 matters
        bne clear2              ; Inverted
        jsr setbit              ; Offset and bit mask still in X and Y
        jmp nclear2
clear2  jsr clrbit
nclear2 dec bitctr
end2    ldx scandown
        bne down
        dec currow
        bpl contcol
        lda #$2e
        jsr chrout              ; Print single "." for column
        inc currow
        ldx curcol
        dex
        cpx #6                  ; Column to skip entirely
        bne ncskip1
        dex
ncskip1 stx curcol
        lda #1
        sta scandown
        bne ncont
down    ldx currow
        inx
        stx currow
        cpx nummod
        bne contcol
        lda #$2e
        jsr chrout              ; Print single "." for column
        dex
        stx currow
        ldx curcol
        dex
        cpx #6                  ; Column to skip entirely
        bne ncskip2
        dex
ncskip2 stx curcol
        lda #0
        sta scandown
        beq ncont
contcol inc curcol
ncont   ldx bitctr
        jmp loop
done    .)

        lda #1
        sta borderclr
        sta bgclr
        PRINT(clrscr)
