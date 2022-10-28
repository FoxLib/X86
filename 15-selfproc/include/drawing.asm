; ----------------------------------------------------------------------
; Рисование линии методом Брезенхема
; call line(x1 y1 x2 y2 color)
; Необходимо задать константу XRES - ширина
; ----------------------------------------------------------------------
; +1 color; +2 y2; +3 x2; +4 y1; +5 x1
;
; (r2) deltax=|x2-x1| (r3) signx
; (r4) deltay=|y2-y1| (r5) signy
; (r6) error (r7) error2
; (r0) current (r9) end
; ----------------------------------------------------------------------

proc    line(x1,y1,x2,y2,cl): r0-r9

        movu    r0, 0

        ; Рассчитать deltax, signx
        mov     r1, [x1]
        mov     r2, [x2]
        movu    r3, 1           ; signx=1
        sub     r2, r2, r1      ; r2=deltax
        jnc     @f              ; r2<0?
        movs    r3, -1          ; signx=-1
        sub     r2, r0, r2      ; r2=-r2

        ; Рассчитать deltay, signy
@@:     mov     r1, [y1]
        mov     r4, [y2]
        mov     r5, XRES
        sub     r4, r4, r1
        jnc     .start
        mov     r5, -XRES
        sub     r4, r0, r4

        ; (r6) error = deltax - deltay
.start: sub     r6, r2, r4
        mov     r7, XRES
        mov     r8, $c0000
        mov     r0, [y1]            ; r0 = $c0000 + XRES*y1 + x1
        mul     r0, r7
        mov     r1, [x1]
        add     r1, r0, r1
        add     r0, r1, r8
        mov     r9, [y2]            ; r9 = $c0000 + XRES*y2 + x2
        mul     r9, r7
        mov     r1, [x2]
        add     r1, r9, r1
        add     r9, r1, r8

        ; Процедура рисования
        mov     r1, [cl]            ; pset(x1,y1), color
.pset:  movb    [r0], r1            ; Рисовать точку
        cmp     r0, r0, r9          ; Тест на попадание в линию
        jz      .exit
        add     r7, r6, r6          ; err2=2*error
        add     r8, r7, r4          ; === Коррекция по X ===
        js      @f                  ; if (error2 + deltay >= 0)
        sub     r6, r6, r4          ; err -= deltay
        add     r0, r0, r3          ; +signx
@@:     sub     r8, r7, r2          ; == Коррекция по Y ===
        jns     .pset               ; if (error2 - deltay < 0)
        add     r6, r6, r2          ; error += deltax
        add     r0, r0, r5          ; +signy
        jmp     .pset
.exit:
endp

; ----------------------------------------------------------------------
; Заполнение экрана сплошным цветом
; ----------------------------------------------------------------------

proc    fillall(cl): r0-r2
        mov     r1, [cl]
        mov     r2, r1          ; Заполнение цветом 4 байт
        shl     r1, 8           ; r1=0000CC00
        or      r2, r2, r1
        mov     r1, r2          ; r1=0000CCCC
        shl     r2, 16          ; r2=CCCC0000
        or      r2, r2, r1      ; r2=CCCCCCCC
        mov     r1, XRES*YRES/4
        mov     r0, 0xc0000
@@:     movd    [r0], r2        ; Чтобы тут быстрее работало
        addb    r0, 4
        dec     r1
        jnz     @b
endp

; ----------------------------------------------------------------------
; Рисовать блок
; ----------------------------------------------------------------------

proc    drawblock(x1,y1,w,h,cl): r0-r5
map     dx:r4, dy:r2

        mov     r1, XRES
        mov     r2, $c0000
        mov     r0, [x1]        ; r0=$c0000 + y1*640 + x1
        mov     r3, [y1]
        mul     r3, r1
        add     r3, r3, r0
        add     r0, r3, r2
        mov     dy, [h]
        mov     r3, [cl]        ; Цвет
.YLn:   mov     dx, [w]
.XLn:   movb    [r0], r3
        inc     r0              ; X++
        dec     dx
        jnz     .XLn
        mov     dx, [w]
        sub     r0, r0, dx      ; X -= dx
        add     r0, r0, r1      ; Y++
        dec     dy
        jnz     .YLn
endp
