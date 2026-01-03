        .(
        ;; Display QR code matrix
        curcol = tmp4
        currow = tmp5
        scr_rowoffs = tmp6
        scraddr = tmp9
        base = scrmem + 2*40 + 10 ; Row 2, column 10
        lda #<base
        sta scraddr
        lda #>base
        sta scraddr + 1
        lda #0
        sta curcol
        sta currow
        sta scr_rowoffs
loop    lda curcol
        sta tmp1
        lda currow
        sta tmp2
        jsr getbits
        tax
        lda matcds,x
        ldy scr_rowoffs
        sta (scraddr),y
        iny
        sty scr_rowoffs
        ldy curcol
        iny
        iny
        sty curcol
        cpy nummod
        bmi loop
        lda scraddr
        clc
        adc #40
        sta scraddr
        lda scraddr + 1
        adc #0
        sta scraddr + 1
        ldy #0
        sty curcol
        sty scr_rowoffs
        ldy currow
        iny
        iny
        sty currow
        cpy nummod
        bmi loop
        .)
