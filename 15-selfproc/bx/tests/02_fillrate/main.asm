
        ; Просто запись в память
        mov     r1, 0x03030303
L1:     mov     r0, 0xC0000
        mov     r2, 640*400/4
@@:     movd    [r0], r1
        addb    r0, 4
        subb    r2, 1
        jnz     @b
        add     r1, 0x01000000
@@:     jmp     L1
