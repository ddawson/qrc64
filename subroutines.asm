findbit .(
        ;; Find offset and bit mask of specific bit in QR matrix
        ;; Column in tmp1, row in tmp2.
        ;; Leaves offset in Y and bit number in X
        lda tmp2
        asl                     ; row offset = row * 6
        clc
        adc tmp2
        asl
        sta tmp2

        lda tmp1
        lsr                     ; byte within row = col / 8
        lsr
        lsr
        clc
        adc tmp2
        tay                     ; Y has byte offset in matrix
        lda tmp1
        and #7                  ; bit number is lower 3 bits of col
        tax
        rts
        .)

setbit  .(
        ;; Set specific bit in QR matrix to 1, given byte offset in Y,
        ;; bit number in X
        lda bittbl,x
        ora qmatrix,y
        sta qmatrix,y
        lda bittbl,x
        ora moccupy,y           ; mark bit as occupied
        sta moccupy,y
        rts
        .)

clrbit  .(
        ;; Clear specific bit in QR matrix to 0, given byte offset in Y,
        ;; bit number in X
        lda bittbl,x
        eor #$ff                ; invert
        and qmatrix,y
        sta qmatrix,y
        lda bittbl,x
        ora moccupy,y           ; mark bit as occupied
        sta moccupy,y
        rts
        .)

chkbit  .(
        ;; Check whether specific bit in QR matrix has been set/cleared,
        ;; given byte offset in Y and bit number in X
        lda bittbl,x
        and moccupy,y
        rts                     ; Z will be clear if true
        .)

setrect .(
        ;; Set bits in rectangle from (tmp3, tmp4) to (tmp5, tmp6) (exclusive)
        col = tmp3
        row = tmp4
        endcol = tmp5
        endrow = tmp6
        startcol = tmp7
        lda col
        sta startcol
loop    lda col
        sta tmp1
        lda row
        sta tmp2
        jsr findbit
        jsr setbit
        inc col
        lda col
        cmp endcol
        bne loop
        lda startcol
        sta col
        inc row
        lda row
        cmp endrow
        bne loop
        rts
        .)

clrrect .(
        ;; Clear bits in rectangle from (tmp3, tmp4) to (tmp5, tmp6) (excl.)
        col = tmp3
        row = tmp4
        endcol = tmp5
        endrow = tmp6
        startcol = tmp7
        lda col
        sta startcol
loop    lda col
        sta tmp1
        lda row
        sta tmp2
        jsr findbit
        jsr clrbit
        inc col
        lda col
        cmp endcol
        bne loop
        lda startcol
        sta col
        inc row
        lda row
        cmp endrow
        bne loop
        rts
        .)

althorz .(
        ;; Create alternating pattern, row tmp3, from tmp4 to tmp5 (exclusive)
        row = tmp3
        cur = tmp4
        end = tmp5
        lda cur
loop    sta tmp1
        lda row
        sta tmp2
        jsr findbit
        jsr setbit
        inc cur
        lda cur
        cmp end
        beq done
        sta tmp1
        lda row
        sta tmp2
        jsr findbit
        jsr clrbit
        inc cur
        lda cur
        cmp end
        bne loop
done    rts
        .)

altvert .(
        ;; Create alternating pattern, col tmp3, from tmp4 to tmp5 (exclusive)
        col = tmp3
        cur = tmp4
        end = tmp5
        lda cur
loop    sta tmp2
        lda col
        sta tmp1
        jsr findbit
        jsr setbit
        inc cur
        lda cur
        cmp end
        beq done
        sta tmp2
        lda col
        sta tmp1
        jsr findbit
        jsr clrbit
        inc cur
        lda cur
        cmp end
        bne loop
done    rts
        .)

mkfindr .(
        ;; Draw finder pattern with upper-left corner at (tmp9, tmp10)
        left = tmp9
        top = tmp10
        startcol = tmp3
        startrow = tmp4
        endcol = tmp5
        endrow = tmp6

        ;;; Outer square
        lda left
        sta startcol
        clc
        adc #7
        sta endcol
        lda top
        sta startrow
        adc #7
        sta endrow
        jsr setrect

        ;;; Cleared square
        lda left
        clc
        adc #1
        sta startcol
        adc #5
        sta endcol
        lda top
        adc #1
        sta startrow
        adc #5
        sta endrow
        jsr clrrect

        ;;; Center square
        lda left
        clc
        adc #2
        sta startcol
        adc #3
        sta endcol
        lda top
        adc #2
        sta startrow
        adc #3
        sta endrow
        jsr setrect

        rts
        .)

mkalgn  .(
        ;; Draw alignment pattern with upper-left corner at (tmp9, tmp10)
        left = tmp9
        top = tmp10
        startcol = tmp3
        startrow = tmp4
        endcol = tmp5
        endrow = tmp6

        ;;; Outer square
        lda left
        sta startcol
        clc
        adc #5
        sta endcol
        lda top
        sta startrow
        adc #5
        sta endrow
        jsr setrect

        ;;; Inner square
        lda left
        clc
        adc #1
        sta startcol
        adc #3
        sta endcol
        lda top
        adc #1
        sta startrow
        adc #3
        sta endrow
        jsr clrrect

        ;;; Center module
        lda left
        clc
        adc #2
        sta tmp1
        lda top
        adc #2
        sta tmp2
        jsr findbit
        jsr setbit

        rts
        .)

getbits .(
        ;; Get value of 2x2 square of bits with upper-left at (tmp1, tmp2)
        bitnum = tmp3
        lda tmp2
        asl                     ; row offset = row * 6
        cls
        adc tmp2
        asl
        sta tmp2

        lda tmp1
        lsr                     ; byte within row = col / 8
        lsr
        lsr
        clc
        adc tmp2
        tay                     ; Y has byte offset in matrix
        lda tmp1
        and #7                  ; bit number is lower 3 bits of col
        lsr                     ; groups of 2 bits
        sta bitnum
        lda #3
        sec
        sbc bitnum              ; reverse numbering
        sta bitnum
        tax
        lda dbittbl,x           ; get bit mask
        and qmatrix,y
sloop1  dex
        bmi sdone1
        lsr
        lsr
        bpl sloop1
sdone1  asl
        asl
        sta tmp2
        tya
        clc
        adc #6                  ; go down a row
        tay
        ldx bitnum
        lda dbittbl,x
        and qmatrix,y
sloop2  dex
        bmi sdone2
        lsr
        lsr
        bpl sloop2
sdone2  ora tmp2
        rts
        .)
