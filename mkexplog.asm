        .(
        ;; Create exp and log tables
        ;; Formally, we keep multiplying the exp value by 2, and if it is
        ;; 256 or higher, XOR by the primitive polynomial that is greater than
        ;; 256. But since this always clears bit 8, 6502 allows us to just
        ;; check the carry flag to see if the number is 256 or higher (since a
        ;; single left-shift is guaranteed to set the flag in this way), and if
        ;; it is, XOR with the lower 8 bits of the primitive polynomial

        ldx #0
        lda #1
loop    sta gf_exp,x
        tay
        txa
        sta gf_log,y
        tya
        asl
        bcc nomod
        eor #prim               ; GF mod by primitive
nomod   inx
        bne loop
        lda #0                  ; Fix to be mod 255 (slightly more efficient)
        sta gf_log+1
        .)
