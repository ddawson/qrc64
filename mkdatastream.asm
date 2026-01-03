        .(
        ;; Get message from user
        PRINT(mprompt)
        ldy #0
loop    jsr chrin
        cmp #$0d
        beq done
        sta input,y
        iny
        bne loop
done    sty inplen
        .)

        ;; ECI indicator (UTF-8), binary mode
        lda #$71
        sta ecibin
        lda #$a4
        sta ecibin + 1

        .(
        ;; Translate and encode to UTF-8
        inpidx = tmp1
        utfctr = tmp2
        ldx #0
        stx inpidx
        ldy #0
loop    cpx inplen
        beq done
        lda input,x
        bpl msbclr              ; MSB set handled separately
        cmp #$a0
        bmi noout
        cmp #$c0
        bmi trans2
        cmp #$e0
        bpl shftupr
        sec
        sbc #$60
        bne trans1
shftupr cmp #$ff
        beq shftlst
        sec
        sbc #$40
        bne trans2
shftlst lda #$7e
        bne trans1
msbclr  cmp #$20
        bmi noout
        cmp #$40
        bmi asis
trans1  tax
        lda #2
        bit memsetup            ; Check which charset is in effect
        bne lc1
        lda uctbl1,x
        bne lookups
lc1     lda lctbl1,x
        bne lookups
trans2  tax
        lda #2
        bit memsetup            ; Check which charset is in effect
        bne lc2
        lda uctbl2,x
        bne lookups
lc2     lda lctbl2,x
lookups bpl asis
        tax
        lda utflens,x
        sta utfctr
        lda utfoffs,x
        tax
trnslp  lda utftbl,x
        sta trinput,y
        inx
        iny
        beq done                ; Can output one page max
        dec utfctr
        bne trnslp
        inc inpidx
        ldx inpidx
        bne loop
asis    sta trinput,y
        iny
        beq done                ; Can output one page max
noout   inc inpidx
        ldx inpidx
        beq done
        jmp loop
done    sty trinpln
        lda #0
        sta trinput,y
        iny                     ; Include bitstream overhead
        iny
        iny
        sty strlen
        .)

eclloop .(
        ;; Get EC level choice from user
        PRINT(lprompt)
get     jsr getin
        beq get
        cmp #$4C                ; L
        bne not_l
        lda #1
        bne done
not_l   cmp #$4D                ; M
        bne not_m
        lda #0
        beq done
not_m   cmp #$51                ; Q
        bne not_q
        lda #3
        bne done
not_q   cmp #$48                ; H
        bne eclloop
        lda #2
done    sta eclevel
        .)

        .(
        ;; Look for suitable version for msg length/EC level.
        tax
        ldy #0
loop    iny
        cpy #7
        bpl toobig
        inx
        inx
        inx
        inx
        lda scaptbl,x
        cmp strlen
        bmi loop
        sta strcap
        sty version
        tya
        asl
        asl
        clc
        adc #17
        sta nummod
        bne gotvers
toobig  PRINT(badparm)
        jmp eclloop
gotvers .)

        .(
        ;; Look up parameters for this version/EC level
        tya                     ; Y still has version
        asl
        asl
        ora eclevel
        tax
        lda nblktbl,x
        sta numblks
        lda ecsztbl,x
        sta ecsize
        lda version
        asl
        asl
        asl
        asl
        sta tmp1
        lda eclevel
        asl
        asl
        ora tmp1
        tax
        ldy #0
loop1   lda dsztbl,x
        sta bdszs,y
        inx
        iny
        cpy #4
        bne loop1
        lda #0
        sta bdoffs
        ldx #0
        clc
loop2   adc bdszs,x
        sta bdoffs + 1,x
        inx
        cpx #3
        bne loop2
        adc bdszs,x             ; Total size of data blocks
        sta tmp1
        lda #0
        sta ecoffs
        ldx #0
        clc
loop3   adc ecsize
        sta ecoffs + 1,x
        inx
        cpx #3
        bne loop3
        adc ecsize
        adc tmp1
        sta ttlsize
        .)

        .(
        ;; Fill unused bytes
        ldx strlen
        cpx strcap
        beq done                ; No space for even termination marker
        inx
        stx strlen              ; Allow null to take up space
        lda strcap
        sec
        sbc strlen
        tay
        beq done
loop    lda #filler1
        sta stream,x
        inx
        dey
        beq done
        lda #filler2
        sta stream,x
        inx
        dey
        bne loop
done    .)

        PRINT(fmtstrm)
