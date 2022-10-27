
transparent         db 0
draw_method         dw 0

; ----------------------------------------------------------------------
; Закрашенная окружность в точке SI=X, DI=Y, радиус (BX) цвет DL
; ----------------------------------------------------------------------

cfill:      push    bp cx

            mov     ax, 0           ; x
            mov     bp, 3
            sub     bp, bx
            sub     bp, bx          ; bp=3-2*y
.cloop:     cmp     ax, bx
            ja      .exit           ; x > y?
            xchg    ax, bx
            call    .drawtwo        ; Левая и правая
            xchg    ax, bx
            imul    cx, ax, 4       ; d += 4*x+6
            add     bp, cx
            add     bp, 6
            js      @f              ; if d >= 0:
            call    .drawtwo        ; Нижняя и верхняя
            mov     cx, 1           ; d += 4*(1-y)
            sub     cx, bx
            shl     cx, 2
            add     bp, cx
            dec     bx              ; y--
@@:         inc     ax              ; x++
            jmp     .cloop

.exit:      pop     cx bp
            ret

            ; Рисование двух линии
.drawtwo:   add     di, bx          ; di=yc+y
            call    .horiz          ; line(xc - a, yc + b, xc + a, yc + b, color);
            sub     di, bx
            sub     di, bx
            call    .horiz          ; line(xc - a, yc - b, xc + a, yc - b, color);
            add     di, bx
            ret

            ; dx=(yc+bx)*320 + (xc-ax)
.horiz:     push    di ax cx
            cmp     di, 200
            jnb     @f
            imul    di, 320
            add     di, si
            sub     di, ax
            mov     cx, ax
            add     cx, ax
            inc     cx
            mov     al, dl
            rep     stosb
@@:         pop     cx ax di
            ret

; ----------------------------------------------------------------------
; Фоновая картинка
; ----------------------------------------------------------------------

draw_bg0:   ; Очистить в определенный цвет
            mov     di, 0
            mov     al, [imagedata+512+128*34+96]
            mov     cx, 64000
            rep     stosb

            ; Горы
            xor     dx, dx
            mov     si, bg_mountain
            mov     bp, 128*150

.L2:        lodsw
            and     ax, ax
            je      .circ
            xchg    ax, cx
            lodsw

.L1:        sub     bp, ax
            mov     bx, bp
            shr     bx, 7
            imul    di, bx, 320
            add     di, dx
            push    ax
            mov     al,  [imagedata+512+128*33+96]
.L0:        mov     [es:di], al
            add     di, 320
            jnc     .L0
            pop     ax
            inc     dx
            loop    .L1
            jmp     .L2

.circ:      ; Нарисовать круги
            mov     bp, bg_circles+2
            mov     cx, [bp-2]
@@:         mov     si, [bp]
            mov     di, [bp+2]
            add     di, 10
            mov     bx, [bp+4]
            mov     dl, [imagedata+512+128*32+96]
            call    cfill
            add     bp, 6
            loop    @b
            ret

; ----------------------------------------------------------------------
; Тайловый передний план
; ----------------------------------------------------------------------

draw_bg1:   mov     dh, $00
.L1:        mov     dl, $00
.L0:        lodsb
            call    draw_tile
            add     dl, 8
            cmp     dl, 20*8
            jne     .L0
            add     dh, 8
            cmp     dh, 12*8
            jne     .L1
            ret

; ----------------------------------------------------------------------
; Рисование фона
; AL - i|j; позиция спрайта из таблицы
; DH - y/2, DL - x/2; позиция тайла
; ----------------------------------------------------------------------

draw_tile:  push    ax bx cx dx si di

            ; Выбор метода рисования
            mov     [draw_method], DRAW00
            test    al, $08
            je     @f
            mov     [draw_method], DRAW10

@@:         mov     ah, al
            shr     ah, 4
            and     ax, $0707       ; 16x16 количество спрайтов
            mov     bl, ah          ; Источник данных
            mov     bh, 0
            shl     bx, (4+7)       ; *128*16
            mov     ah, 0
            shl     ax, 4           ; *16
            add     bx, ax
            lea     si, [bx+imagedata+512]
            mov     al, dh          ; Позиция луча
            mov     ah, 0
            imul    di, ax, 2*320  ; di=320*2*dh + 16*dl
            add     di, 8*320
            mov     al, dl
            shl     ax, 1
            add     di, ax
            call    [draw_method]
            pop     di si dx cx bx ax
            ret

; ------------------------------
; Слева направо, сверху вниз
; ------------------------------

DRAW00:     cld
            mov     dx, 16
            mov     bl, [transparent]
.S2:        mov     cx, 16
.S1:        lodsb
            cmp     al, bl
            je      @f
            stosb
            dec     di
@@:         inc     di
            loop    .S1
            add     di, 320-16
            add     si, 128-16
            dec     dx
            jne     .S2
            ret

; ------------------------------
; Справа направо, сверху вниз
; ------------------------------

DRAW10:     std
            mov     dx, 16
            mov     bl, [transparent]
.S2:        mov     cx, 16
            add     si, 15
.S1:        std
            lodsb
            cld
            cmp     al, bl
            je      @f
            stosb
            dec     di
@@:         inc     di
            loop    .S1
            add     di, 320-16
            add     si, 128+1
            dec     dx
            jne     .S2
            cld
            ret

; ----------------------------------------------------------------------
; РИСОВАТЬ СПРАЙТ AX (BX-x, CX-y)
; ----------------------------------------------------------------------

drawsp:     imul    di, cx, 320
            add     di, bx
            xchg    ax, bx
            shl     bx, 2
            lea     si, [bx + sprites]

            ; SI-источник данных
            mov     ah, 0
            mov     bh, 0
            mov     ch, 0
            mov     dh, 0
            mov     cl, [si+2]      ; CX->W
            mov     dl, [si+3]      ; DX->H
            mov     bl, [si+1]
            shl     bx, 7           ; 128*Y
            mov     al, [si+0]
            add     bx, ax
            mov     si, bx          ; 128*Y+X
            add     si, imagedata+512
            mov     bp, bg_sprite

.L1:        push    cx
.L0:        lodsb
            mov     ah, [es:di]     ; Сохранить пиксели за спрайтом
            mov     [bp], ah
            inc     bp
            cmp     al, [transparent]
            je      @f
            mov     [es:di], al
@@:         inc     di
            loop    .L0
            pop     cx
            sub     bp, cx
            sub     di, cx
            sub     si, cx
            add     bp, 32
            add     si, 128
            add     di, 320
            dec     dx
            jne     .L1
            ret

            ; Тест на наличие области в данном (X,Y)
            ; Область всегда 24x16
            ; Действие -- удалить область и перекрасить новую
            ; Просмотр списка активных в данный момент спрайтов

; ----------------------------------------------------------------------
; Палитра
; ----------------------------------------------------------------------

palette:    mov     dx, 968
            xor     ax, ax
            out     dx, al
            inc     dx
            xor     cx, cx
            mov     si, imagedata
@@:         lodsw
            cmp     ax, $F0F
            jne     .S0
            mov     [transparent], cl
.S0:        mov     bx, ax
            shr     ax, 8
            shl     ax, 2
            out     dx, al      ; R
            mov     al, bl
            and     al, $F0
            shr     al, 2
            out     dx, al      ; G
            mov     al, bl
            and     al, $0F
            shl     al, 2
            out     dx, al      ; B
            inc     cx
            cmp     cx, $100
            jne     @b
            ret
