        .(
        ;; Zero generator polynomial area
        ldx #ecmaxsize
        lda #0
loop    sta genpol,x
        dex
        bpl loop
        .)

        .(
        ;; Create generator polynomial
        degree = tmp1
        factor = tmp2
        lda #1
        sta genpol
        ldx #0
        stx degree
        ldy #0
outer   lda gf_exp,x
        sta factor
inner   lda genpol,y
        beq skip
        tax
        lda gf_log,x
        ldx factor
        clc
        adc gf_log,x
        tax
        bcc noadj
        inx                     ; GF mod by 255
noadj   lda gf_exp,x
skip    eor genpol + 1,y
        sta genpol + 1,y
        ldx degree
        dey
        bpl inner
        inx
        stx degree
        ldy degree
        cpx ecsize
        bne outer
        .)

        PRINT(madegen)
