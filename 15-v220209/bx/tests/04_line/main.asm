
        org     0
XRES    equ     640
YRES    equ     400

        movu    r3, 0
Ab:     mov     r2, (XRES-1)

@@:     call    line(0, 0, r2, 399, r3)
        inc     r3
        dec     r2
        jnz     @b

        mov     r2, (YRES-1)
@@:     call    line(0, 0, 639, r2, r3)
        inc     r3
        dec     r2
        jnz     @b

        jmp     Ab

include "../../../include/drawing.asm"

