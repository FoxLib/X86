
        org     100h

        mov     ax, $B800
        mov     es, ax
        mov     ax, $0020
        mov     ds, ax

        ; Очистка флагов
        xor     ax, ax
        push    ax
        popf
        mov     ax, $AF23
        mov     bx, $1234
        mov     cx, $5231
        mov     dx, $BAF0
        mov     bp, $2234
        mov     si, $01AE
        mov     di, $BCD0

; ----------------------------------------------------------------------
@@:
        add     ax, bx
        add     bx, cx
        add     cx, ax
        add     dx, bp
        add     bp, si
        add     si, di
        add     di, ax
        loop    @b
        pushf
        cmp     ax, $F980
        jne     .E0
        cmp     bx, $376B
        jne     .E0
        cmp     dx, $C878
        jne     .E0
        cmp     bp, $ADCB
        jne     .E0
        cmp     si, $F59C
        jne     .E0
        cmp     di, $0F70
        jne     .E0
        pop     ax
        and     ax, $08FF
        cmp     ax, $0003
        jne     .E0
        mov     [es:0], word $2F20
        jmp     .V0
.E0:    mov     [es:0], word $4F21
        jmp     $
; ----------------------------------------------------------------------
.V0:    adc     ax, bx
        adc     bx, cx
        adc     cx, ax
        adc     dx, bp
        adc     bp, si
        adc     si, di
        adc     di, ax
        loop    .V0
        cmp     ax, $89BC
        jne     .E1
        cmp     bx, $0469
        jne     .E1
        cmp     dx, $A8A1
        jne     .E1
        cmp     si, $B297
        jne     .E1
        cmp     di, $C981
        jne     .E1
        cmp     bp, $6823
        jne     .E1
        and     ax, $08FF
        cmp     ax, $08BC
        jne     .E1
        mov     [es:2], word $2F20
        jmp     .V1
.E1:    mov     [es:2], word $4F21
        jmp     $
; ----------------------------------------------------------------------
.V1:
@@:     sub     ax, bx
        sub     bx, cx
        sub     cx, ax
        sub     dx, bp
        sub     bp, si
        sub     si, di
        sub     di, ax
        loop    @b
        pushf
        cmp     ax, $D9EC
        jne     @f
        cmp     bx, $4FE9
        jne     @f
        cmp     dx, $5177
        jne     @f
        cmp     si, $B75B
        jne     @f
        cmp     di, $32B9
        jne     @f
        cmp     bp, $280F
        jne     @f
        pop     ax
        and     ax, $08FF
        cmp     ax, $0013
        jne     @f
        mov     [es:4], word $2F20
        jmp     .V2
@@:     mov     [es:4], word $4F21
        jmp     $
; ----------------------------------------------------------------------
.V2:
@@:     sbb     ax, bx
        sbb     bx, cx
        sbb     cx, ax
        sbb     dx, bp
        sbb     bp, si
        sbb     si, di
        sbb     di, ax
        loop    @b
        pushf
        cmp     ax, $8BC6
        jne     @f
        cmp     bx, $ECEF
        jne     @f
        cmp     dx, $03A0
        jne     @f
        cmp     si, $8015
        jne     @f
        cmp     di, $35D1
        jne     @f
        cmp     bp, $EA92
        jne     @f
        pop     ax
        and     ax, $08FF
        cmp     ax, $0006
        jne     @f
        mov     [es:6], word $2F20
        jmp     .V3
@@:     mov     [es:6], word $4F21
        jmp     $
; ----------------------------------------------------------------------
.V3:
@@:     xor     ax, bx
        xor     bx, cx
        xor     cx, dx
        xor     dx, bp
        xor     bp, si
        xor     si, di
        xor     di, ax
        loop    @b
        pushf
        cmp     ax, $8353
        jne     @f
        cmp     bx, $659F
        jne     @f
        cmp     dx, $9A4D
        jne     @f
        cmp     si, $C5CD
        jne     @f
        cmp     di, $6F42
        jne     @f
        cmp     bp, $CFAA
        jne     @f
        pop     ax
        and     ax, $08FF
        cmp     ax, $0006
        jne     @f
        mov     [es:8], word $2F20
        jmp     .V4
@@:     mov     [es:8], word $4F21
        jmp     $

; ----------------------------------------------------------------------
.V4:
        int3
@@:     add     ax, bx
        adc     bx, cx
        sub     cx, dx
        sbb     dx, bp
        and     bp, si
        or      si, di
        sub     si, ax
        xor     di, dx
        loop    @b
        pushf
        cmp     ax, $13CD
        jne     @f
        cmp     bx, $30A7
        jne     @f
        cmp     dx, $01DC
        jne     @f
        cmp     si, $5312
        jne     @f
        cmp     di, $2793
        jne     @f
        cmp     bp, $0000
        jne     @f
        pop     ax
        and     ax, $08FF
        cmp     ax, $0006
        jne     @f
        mov     [es:10], word $2F20
        jmp     .V5
@@:     mov     [es:10], word $4F21
        jmp     $
; ----------------------------------------------------------------------
.V5:

print_ax:

        mov     cx, 4
        mov     si, 0
@@:     rol     ax, 4
        mov     bx, ax
        and     al, $0F
        cmp     al, 10
        jb      $+4
        add     al, 7
        add     al, '0'
        mov     [es:si], al
        inc     si
        inc     si
        mov     ax, bx
        loop    @b
        jmp     $
