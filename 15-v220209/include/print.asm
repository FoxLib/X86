
; Печать строки с прозрачным фоном
proc    printstr(x,y,str,color): r0-r8

        mov     r0, $c0000
        mov     r1, [y]
        mov     r7, XRES
        mul     r1, r7
        mov     r2, [x]
        add     r1, r1, r2
        add     r0, r1, r0      ; r0 = $c0000 + 640*y + x
        addb    r0, 7
        mov     r3, fonts
        mov     r4, [color]
        mov     r8, [str]
.L3:    movb    r1, [r8]        ; r1 = ascii код
        inc     r8
        cmpb    r1, 0
        jz      .end
        shl     r1, 3
        add     r1, r1, r3      ; r1=[r1]<<3 + fonts
        movu    r6, 8
.L2:    movu    r5, 8
        movb    r2, [r1]        ; r2=mask
.L1:    shr     r2, 1
        jnc     @f
        movb    [r0], r4
@@:     dec     r0
        dec     r5
        jnz     .L1
        inc     r1
        addb    r0, 8
        add     r0, r0, r7
        dec     r6
        jnz     .L2
        mov     r2, XRES*8      ; r0 += 8*640+8
        sub     r0, r0, r2
        addb    r0, 8
        jmp     .L3

.end:
endp
