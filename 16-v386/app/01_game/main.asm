
            org     100h

            mov     ax, $A000
            mov     es, ax
            mov     ax, $0013
            int     10h
            call    palette

            call    draw_bg0

            mov     si, level0
            call    draw_bg1

            mov     ax, 0
            mov     bx, 140
            mov     cx, 169
            call    drawsp

            sti
@@:         call    timer
            jmp     $

; ----------------------------------------------------------------------

___         equ $00
include     "control.asm"
include     "graphics.asm"
include     "data.asm"
