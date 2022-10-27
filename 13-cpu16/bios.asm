        org     0
        mov     ax, $1721
        mov     bx, $b800
        mov     cx, 2000
@@:     mov     [bx], ax
        inc     bx
        inc     bx
        loop    @b        
        jmp     $
