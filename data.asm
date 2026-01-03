mprompt .asc $93, "enter message (up to 79 chars.). this", $0d
        .asc "will be converted to utf-8. be warned", $0d
        .asc "that non-ascii characters, including ", $5c, $0d
        .asc "and pi, will take multiple bytes each", $0d
        .asc "(3 or 4 for graphics chars.). the", $0d
        .asc "active charset determines the mapping", $0d
        .asc "that will be used.", $0d, 0
lprompt .asc $0d, "choose error corr. level (l, m, q, h):", $0d, 0
badparm .asc "message too big. try lower level.", $0d, 0
fmtstrm .asc "formatted stream.", $0d, 0
madegen .asc "created generator polynomial.", $0d, 0
calcecc .asc "calculated ecc for block ", 0
intldn  .asc "interleaved ecc blocks.", $0d, 0
drewfix .asc "drew fixed patterns.", $0d, 0
drewfmt .asc "added format metadata.", $0d, 0
drawdat .asc "setting data.", 0
clrscr  .asc $90, $93, 0

;; Substitution tables (MSB set means use a UTF-8 sequence)
;; Uppercase/graphics set, $40 - $7f
uctbl1  = * - $40
        .byt $40, $41, $42, $43, $44, $45, $46, $47
        .byt $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
        .byt $50, $51, $52, $53, $54, $55, $56, $57
        .byt $58, $59, $5a, $5b, $80, $5d, $81, $82
        .byt $83, $84, $85, $82, $86, $87, $88, $89
        .byt $8a, $8b, $8c, $8d, $8e, $8f, $90, $91
        .byt $92, $93, $94, $95, $96, $97, $98, $99
        .byt $9a, $9b, $9c, $9d, $9e, $85, $9f, $a0

;; Uppercase/graphics set, $a0 - $bf
uctbl2  = * - $a0
        .byt $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa
        .byt $ab, $ac, $aa, $ad, $ae, $af, $b0, $b1
        .byt $b2, $b3, $b4, $b5, $a8, $b6, $b7, $b8
        .byt $b9, $ba, $bb, $bc, $bd, $be, $bf, $c0

;; Lowercase/uppercase set, $40 - $7f
lctbl1  = * - $40
        .byt $40, $61, $62, $63, $64, $65, $66, $67
        .byt $68, $69, $6a, $6b, $6c, $6d, $6e, $6f
        .byt $70, $71, $72, $73, $74, $75, $76, $77
        .byt $78, $79, $7a, $5b, $80, $5d, $81, $82
        .byt $83, $41, $42, $43, $44, $45, $46, $47
        .byt $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
        .byt $50, $51, $52, $53, $54, $55, $56, $57
        .byt $58, $59, $5a, $9d, $9e, $9f, $a1, $a2

;; Lowercase/uppercase set, $a0 - $bf
lctbl2  = * - $a0
        .byt $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa
        .byt $ab, $c1, $aa, $ad, $ae, $af, $b0, $b1
        .byt $b2, $b3, $b4, $b5, $a8, $b6, $b7, $b8
        .byt $b9, $ba, $c2, $bc, $bd, $be, $bf, $c0

;; Offsets of sequences in UTF-8 block
utfoffs = * - $80
        .byt   0,   2,   5,   8, $0b, $0e, $11, $15
        .byt $19, $1d, $21, $25, $28, $2b, $2e, $32
        .byt $35, $38, $3c, $40, $43, $47, $4a, $4e
        .byt $51, $54, $57, $5a, $5e, $61, $64, $68
        .byt $6a, $6d, $71, $75, $77, $7a, $7d, $80
        .byt $83, $86, $8a, $8d, $91, $94, $97, $9a
        .byt $9d, $a0, $a3, $a6, $a9, $ac, $af, $b2
        .byt $b6, $ba, $be, $c1, $c5, $c8, $cb, $ce
        .byt $d1, $d4, $d8

;; Lengths of UTF-8 sequences
utflens = * - $80
        .byt   2,   3,   3,   3,   3,   3,   4,   4
        .byt   4,   4,   4,   3,   3,   3,   4,   3
        .byt   3,   4,   4,   3,   4,   3,   4,   3
        .byt   3,   3,   3,   4,   3,   3,   4,   2
        .byt   3,   4,   4,   2,   3,   3,   3,   3
        .byt   3,   4,   3,   4,   3,   3,   3,   3
        .byt   3,   3,   3,   3,   3,   3,   3,   4
        .byt   4,   4,   3,   4,   3,   3,   3,   3
        .byt   3,   4,   3

;; UTF-8 block
utftbl  .byt $c2, $a3           ; 00 £
        .byt $e2, $86, $91      ; 02 ↑
        .byt $e2, $86, $90      ; 05 ←
        .byt $e2, $94, $80      ; 08 ─
        .byt $e2, $99, $a0      ; 0b ♠
        .byt $e2, $94, $82      ; 0e │
        .byt $f0, $9f, $ad, $b7 ; 11 🭷
        .byt $f0, $9f, $ad, $b6 ; 15 🭶
        .byt $f0, $9f, $ad, $ba ; 19 🭺
        .byt $f0, $9f, $ad, $b1 ; 1d 🭱
        .byt $f0, $9f, $ad, $b4 ; 21 🭴
        .byt $e2, $95, $ae      ; 25 ╮
        .byt $e2, $95, $b0      ; 28 ╰
        .byt $e2, $95, $af      ; 2b ╯
        .byt $f0, $9f, $ad, $bc ; 2e 🭼
        .byt $e2, $95, $b2      ; 32 ╲
        .byt $e2, $95, $b1      ; 35 ╱
        .byt $f0, $9f, $ad, $bd ; 38 🭽
        .byt $f0, $9f, $ad, $be ; 3c 🭾
        .byt $e2, $97, $8f      ; 40 ●
        .byt $f0, $9f, $ad, $bb ; 43 🭻
        .byt $e2, $99, $a5      ; 47 ♥
        .byt $f0, $9f, $ad, $b0 ; 4a 🭰
        .byt $e2, $95, $ad      ; 4e ╭
        .byt $e2, $95, $b3      ; 51 ╳
        .byt $e2, $97, $8b      ; 54 ○
        .byt $e2, $99, $a3      ; 57 ♣
        .byt $f0, $9f, $ad, $b5 ; 5a 🭵
        .byt $e2, $99, $a6      ; 5e ♦
        .byt $e2, $94, $bc      ; 61 ┼
        .byt $f0, $9f, $ae, $8c ; 64 🮌
        .byt $cf, $80           ; 68 π
        .byt $e2, $97, $a5      ; 6a ◥
        .byt $f0, $9f, $ae, $96 ; 6d 🮖
        .byt $f0, $9f, $ae, $98 ; 71 🮘
        .byt $c0, $a0           ; 75 (shift-space)
        .byt $e2, $96, $8c      ; 77 ▌
        .byt $e2, $96, $84      ; 7a ▄
        .byt $e2, $96, $94      ; 7d ▔
        .byt $e2, $96, $81      ; 80 ▁
        .byt $e2, $96, $8f      ; 83 ▏
        .byt $f0, $9f, $ae, $95 ; 86 🮕
        .byt $e2, $96, $95      ; 8a ▕
        .byt $f0, $9f, $ae, $8f ; 8d 🮏
        .byt $e2, $97, $a4      ; 91 ◤
        .byt $e2, $94, $9c      ; 94 ├
        .byt $e2, $96, $97      ; 97 ▗
        .byt $e2, $94, $94      ; 9a └
        .byt $e2, $94, $90      ; 9d ┐
        .byt $e2, $96, $82      ; a0 ▂
        .byt $e2, $94, $8c      ; a3 ┌
        .byt $e2, $94, $b4      ; a6 ┴
        .byt $e2, $94, $ac      ; a9 ┬
        .byt $e2, $94, $a4      ; ac ┤
        .byt $e2, $96, $8d      ; af ▍
        .byt $f0, $9f, $ae, $88 ; b2 🮈
        .byt $f0, $9f, $ae, $82 ; b6 🮂
        .byt $f0, $9f, $ae, $8e ; ba 🮃
        .byt $e2, $96, $83      ; be ▃
        .byt $f0, $9f, $ad, $bf ; c1 🭿
        .byt $e2, $96, $96      ; c5 ▖
        .byt $e2, $96, $9d      ; c8 ▝
        .byt $e2, $94, $98      ; cb ┘
        .byt $e2, $96, $98      ; ce ▘
        .byt $e2, $96, $9a      ; d1 ▚
        .byt $f0, $9f, $ae, $99 ; d4 🮙
        .byt $e2, $9c, $93      ; d8 ✓

;; Bitmasks for addressing bits in matrix
bittbl  .byt $80, $40, $20, $10, 8, 4, 2, 1

;; Bitmasks for addressing bit pairs in matrix
dbittbl .byt $03, $0c, $30, $c0

;; Bitstream capacity per version, EC level (M, L, H, Q)
scaptbl = * - 4                 ; Index 0 unused
        .byt  16,  19,  9, 13
        .byt  28,  34, 16, 22
        .byt  44,  55, 26, 34
        .byt  64,  80, 36, 48
        .byt  86, 108, 46, 62
        .byt 108, 136, 60, 76

;; Number of EC blocks per version, EC level
nblktbl = * - 4                 ; Index 0 unused
        .byt 1, 1, 1, 1
        .byt 1, 1, 1, 1
        .byt 1, 1, 2, 2
        .byt 2, 1, 4, 2
        .byt 2, 1, 4, 4
        .byt 4, 2, 4, 4

;; Sizes of data portions of blocks per version, EC level, block
dsztbl  = * - 16                ; Index 0 unused
        .byt 16,  0,  0,  0,  19,  0, 0, 0,  9,  0,  0,  0, 13,  0,  0,  0
        .byt 28,  0,  0,  0,  34,  0, 0, 0, 16,  0,  0,  0, 22,  0,  0,  0
        .byt 44,  0,  0,  0,  55,  0, 0, 0, 13, 13,  0,  0, 17, 17,  0,  0
        .byt 32, 32,  0,  0,  80,  0, 0, 0,  9,  9,  9,  9, 24, 24,  0,  0
        .byt 43, 43,  0,  0, 108,  0, 0, 0, 11, 11, 12, 12, 15, 15, 16, 16
        .byt 27, 27, 27, 27,  68, 68, 0, 0, 15, 15, 15, 15, 19, 19, 19, 19

;; Sizes of EC in each block per version, EC level
ecsztbl = * - 4                 ; Index 0 unused
        .byt 10,  7, 17, 13
        .byt 16, 10, 28, 22
        .byt 26, 15, 22, 18
        .byt 18, 20, 16, 26
        .byt 24, 26, 22, 18
        .byt 16, 18, 28, 24

;; Graphics character codes for displaying matrix
matcds  .byt $20, $6c, $7b, $62, $7c, $e1, $ff, $fe
        .byt $7e, $7f, $61, $fc, $e2, $fb, $ec, $a0

;; Addresses that are used, without taking up space in PRG file
#define SIZE(size) * = * + size
gf_exp  SIZE($100)
gf_log  SIZE($100)
inplen  SIZE(1)
input   SIZE(maxinp)
strlen  SIZE(1)
stream
ecibin  SIZE(2)
trinpln SIZE(1)
trinput SIZE($100)
eclevel SIZE(1)
version SIZE(1)
nummod  SIZE(1)
strcap  SIZE(1)
numblks SIZE(1)
bdszs   SIZE(4)
bdoffs  SIZE(4)
ecsize  SIZE(1)
ecoffs  SIZE(4)
ttlsize SIZE(1)
genpol  SIZE(ecmaxsize + 1)
respol  SIZE(blkmaxsize)
ecarea  SIZE(ecmaxsize*4)
intrlvd SIZE(totalmaxsize)
intlvsz SIZE(1)
fmtinf1 SIZE(1)
fmtinf2 SIZE(1)
qmatrix SIZE(matrixsize)
moccupy SIZE(matrixsize)
