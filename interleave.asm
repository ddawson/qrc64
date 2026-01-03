        .(
        ldx #0
        ldy #0
        lda numblks
        cmp #1
        beq single
        cmp #2
        beq double
        bne quad

single  .(
loop1   lda stream,x
        sta intrlvd,x
        inx
        cpx bdszs
        bne loop1
        ldy #0
loop2   lda ecarea,y
        sta intrlvd,x
        inx
        iny
        cpy ecsize
        bne loop2
        lda bdszs
        clc
        adc ecsize
        sta intlvsz
        jmp done
        .)

double  .(
        base = tmp1
        SETPTR(stream, bdoffs + 1, base)
loop1   lda stream,y
        sta intrlvd,x
        inx
        lda (base),y
        sta intrlvd,x
        inx
        iny
        cpy bdszs
        bne loop1
        SETPTR(ecarea, ecoffs + 1, base)
        ldy #0
loop2   lda ecarea,y
        sta intrlvd,x
        inx
        lda (base),y
        sta intrlvd,x
        inx
        iny
        cpy ecsize
        bne loop2
        lda bdszs
        asl
        clc
        adc ecsize
        adc ecsize
        sta intlvsz
        jmp done
        .)

quad    .(
        base1 = tmp1
        base2 = tmp3
        base3 = tmp8
        SETPTR(stream, bdoffs + 1, base1)
        SETPTR(stream, bdoffs + 2, base2)
        SETPTR(stream, bdoffs + 3, base3)
loop1   cpy bdszs
        beq skip
        lda stream,y
        sta intrlvd,x
        inx
        lda (base1),y
        sta intrlvd,x
        inx
skip    lda (base2),y
        sta intrlvd,x
        inx
        lda (base3),y
        sta intrlvd,x
        inx
        iny
        cpy bdszs + 2
        bne loop1
        SETPTR(ecarea, ecoffs + 1, base1)
        SETPTR(ecarea, ecoffs + 2, base2)
        SETPTR(ecarea, ecoffs + 3, base3)
        ldy #0
loop2   lda ecarea,y
        sta intrlvd,x
        inx
        lda (base1),y
        sta intrlvd,x
        inx
        lda (base2),y
        sta intrlvd,x
        inx
        lda (base3),y
        sta intrlvd,x
        inx
        iny
        cpy ecsize
        bne loop2
        clc
        lda bdszs
        adc bdszs + 1
        adc bdszs + 2
        adc bdszs + 3
        sta intlvsz
        lda ecsize
        asl
        asl
        adc intlvsz
        sta intlvsz
        .)
done    .)

        PRINT(intldn)
