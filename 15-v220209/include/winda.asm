
; ----------------------------------------------------------------------
proc    window(x1,y1,w,h,str): r0-r9
        mov     r1, [x1]
        mov     r2, [y1]
        mov     r3, [w]
        mov     r4, [h]
        call    drawblock(r1-r4, 7)
        subb    r3, 2
        subb    r4, 2
        addb    r1, 1
        addb    r2, 1
        call    drawblock(r1-r3, 1, 15)
        call    drawblock(r1-r2, 1, r4, 15)
        add     r2, r2, r4
        call    drawblock(r1-r3, 1, 8)
        sub     r2, r2, r4
        add     r1, r1, r3
        call    drawblock(r1-r2, 1, r4, 8)
        sub     r1, r1, r3
        addb    r1, 2
        addb    r2, 2
        subb    r3, 3
        call    drawblock(r1-r3, 14, 1)
        mov     r4, [str]
        addb    r1, 3
        addb    r2, 3
        call    printstr(r1, r2, r4, 15)
endp
