
        ; Просто запись в память        
        movu    r4, 0        
.L2:    mov     r2, r4
        mov     r0, 0xC0000
        mov     r3, 256
.L1:    mov     r1, 256        
@@:     movb    [r0], r2
        addb    r0, 1
        addb    r2, 1
        subb    r1, 1
        jnz     @b
        add     r0, 384
        addb    r2, 1
        subb    r3, 1
        jnz     .L1
        addb    r4, 1
        jmp     .L2
        

