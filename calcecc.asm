        .(
        blknum = tmp7
        blksize = tmp8
        ldx #0
        stx blknum

blkloop .(
        ;; Zero working area
        lda #0
        tax
loop    sta respol,x
        inx
        cpx #blkmaxsize
        bne loop
        .)

        .(
        ;; Copy data chunk into working area
        ldx blknum
        lda bdszs,x
        sta blksize
        lda bdoffs,x
        tax
        ldy #0
loop    lda stream,x
        sta respol,y
        inx
        iny
        cpy blksize
        bne loop
        .)

        .(
        ;; Calculate error correction: divide data by generator
        curbyte = tmp1
        residx = tmp2
        genidx = tmp3
        ldx #0
        stx residx
outer   lda respol,x
        beq skcoef
        sta curbyte
        ldx ecsize
        stx genidx
inner   lda genpol,x            ; Cannot be 0
        tax
        lda gf_log,x
        ldx curbyte
        clc
        adc gf_log,x
        tax
        bcc noadj
        inx                     ; GF mod by 255
noadj   lda gf_exp,x
        tay
        lda residx
        clc
        adc genidx
        tax
        tya
        eor respol,x
        sta respol,x
        dec genidx
        ldx genidx
        bne inner
skcoef  inc residx
        ldx residx
        cpx blksize
        bne outer
        .)

        PRINT(calcecc)
        lda blknum
        ora #$30
        jsr chrout
        lda #$0d
        jsr chrout

        .(
        ;; Copy remainder into EC area
        srcaddr = tmp1
        dstaddr = tmp3
        SETPTR(respol, blksize, srcaddr)
        ldx blknum
        SETPTR_OFFSET_X(ecarea, ecoffs, dstaddr)
        ldy ecsize
        dey
loop    lda (srcaddr),y
        sta (dstaddr),y
        dey
        bpl loop
        .)

        inc blknum
        ldx blknum
        cpx numblks
        beq done
        jmp blkloop
done    .)
