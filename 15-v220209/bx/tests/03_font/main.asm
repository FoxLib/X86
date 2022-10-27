
        org     0

        mov     r0, $c0000
        mov     r2, test_str
@@:     movb    r1, [r2]
        cmpb    r1, 0
        jz      S1
        call    print_char
        addb    r2, 1
        jmp     @b
S1:     hlt

test_str: db "This is test string",0

; ----------------------------------------------------------------------
print_char:

        push    r0-r5           ; Сохранение контекста
        shl     r1, 3
        mov     r2, fonts
        add     r1, r1, r2      ; r1=r1*8+fonts
        addb    r0, 7
        movu    r5, 8           ; H=8
.L2:    movu    r3, 8           ; W=8
        movb    r2, [r1]        ; font mask
.L1:    movu    r4, 15          ; forecolor
        shr     r2, 1           ; сдвиг направо
        jc      @f
        movu    r4, 0
@@:     movb    [r0], r4
        subb    r0, 1
        subb    r3, 1
        jnz     .L1
        add     r0, 640+8
        addb    r1, 1
        subb    r5, 1
        jnz     .L2
        pop     r5-r0
        add     r0, 8
        ret
; ----------------------------------------------------------------------

fonts:  file    "../../../include/font8x8.bin"

