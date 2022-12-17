
; ----------------------------------------------------------------------
; Видеосервис BIOS
; https://ru.wikipedia.org/wiki/INT_10H
; https://stanislavs.org/helppc/int_10.html
; AH=0 Видеорежим | AL=http://www.columbia.edu/~em36/wpdos/videomodes.txt
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; Видеорежим: AL=0..3 TEXT; 13 VGA 320x200
; ----------------------------------------------------------------------

int10_set_vm:

            push    es dx

            mov     es, [cs:seg_40]
            mov     [es:vidmode-bios_data], al
            mov     dx, $3D8

            cmp     al, $03
            je      .text
            cmp     al, $13
            je      .grah
            jmp     .fin

            ; TEXTMODE
.text:      xor     al, al
            out     dx, al
            mov     ax, $0700
            mov     es, [cs:seg_b800]
            mov     cx, 2000
            xor     di, di
            rep     stosw
            jmp     .fin

            ; GRAPHICS
.grah:      mov     al, 3
            out     dx, al
            mov     es, [cs:seg_a000]
            xor     di, di
            mov     cx, 32000
            xor     ax, ax
            rep     stosw

.fin:       pop     dx es
            iret

; ----------------------------------------------------------------------
; Вид курсора
; CH-начальная CL-конечная
; ----------------------------------------------------------------------

int10_set_cshape:

            push    ax dx es
            mov     es, [cs:seg_40]
            mov     word [es:cur_v_end-bios_data], cx
            mov     [es:cursor_visible-bios_data], byte 1
            cmp     ch, cl
            jbe     @f
            mov     [es:cursor_visible-bios_data], byte 0
@@:         mov     dx, 0x3d4
            mov     al, 0x0a
            mov     ah, ch
            out     dx, ax
            inc     al
            mov     ah, cl
            out     dx, ax
            pop     es dx ax
            iret

; ----------------------------------------------------------------------
; Положение и размер курсора
; AX = 0
; CH = начальная строка формы курсора,
; CL = конечная строка формы курсора
; DH = строка, DL = столбец
; ----------------------------------------------------------------------

int10_get_cursor:

            push    es
            mov     es, [cs:seg_40]
            mov     dx, word [es:curpos_x-bios_data]
            mov     cx, word [es:cur_v_end-bios_data]
            xor     ax, ax
            pop     es
            iret

; ----------------------------------------------------------------------
; Прокрутка наверх
; AL = число строк для прокрутки (0 = очистка, CH, CL, DH, DL используются)
; BH = атрибут цвета
; CH = номер верхней строки, CL = номер левого столбца
; DH = номер нижней строки, DL = номер правого столбца
; ----------------------------------------------------------------------

int10_scrollup:

            call    int10_scrollup_routine
            iret

; Общий скроллинг для разных целей
int10_scrollup_routine:

            push    ds es ax bx cx dx
            call    int10_scrollbound
.repeat:    push    ax bx cx dx     ; Прокрутка AL раз
            mov     al, 80
            mul     ch
            add     al, cl
            adc     ah, 0
            add     ax, ax
            mov     di, ax          ; DI = 2*(CH*80 + CL)
            lea     si, [di+160]    ; SI = DI + 160
            sub     dl, cl
            mov     cl, dl          ; CL = X2-X1+1
            sub     dh, ch          ; DH = Y2-Y1
            mov     ch, 0
            inc     cx
@@:         push    si di cx        ; Прокрутить все окно
            rep     movsw
            pop     cx di si
            add     si, 160
            add     di, 160
            dec     dh
            js      @f              ; Защита от DH=0
            jne     @b
@@:         mov     ah, bh
            mov     al, $20
            lea     di, [si-160]
            rep     stosw           ; Закрасить последнюю строку атрибутом BH
            pop     dx cx bx ax
            dec     al
            jne     .repeat
.end:       pop     dx cx bx ax es ds
            ret

; Определение границ области CX:DX
int10_scrollbound:

            mov     ds, [cs:seg_b800]
            mov     es, [cs:seg_b800]
            and     al, al          ; Определение границ
            jne     @f
            mov     al, 25          ; Если AL=0, то очистка экрана
@@:         cmp     ch, 25
            jb      @f
            mov     ch, 24
@@:         cmp     cl, 80
            jb      @f
            mov     cl, 79
@@:         cmp     dh, 25
            jb      @f
            mov     dh, 24
@@:         cmp     dl, 80
            jb      .end
            mov     dl, 79
.end:       ret

; ----------------------------------------------------------------------
; Положение курсора
; DH = строка, DL = столбец
; ----------------------------------------------------------------------

int10_set_cursor:

            push    ax bx dx es
            mov     es, [cs:seg_40]
            mov     word [es:curpos_x-bios_data], dx
            mov     al, dh
            mov     bl, 80
            mul     bl          ; ax = ch*80
            mov     dh, 0
            add     ax, dx
            mov     bl, al
            mov     al, 0eh
            mov     dx, 3d4h
            out     dx, ax      ; старшие 3 бита
            mov     al, 0fh
            mov     ah, bl
            out     dx, ax      ; младшие 8 бит
            pop     es dx bx ax
            iret

; ----------------------------------------------------------------------
; Печать символа в положении текущего курсора в строчном режиме
; AL-символ BL-цвет (только для графики)
; BEL (07h), BS (08h), LF (0Ah), and CR (0Dh)
; ----------------------------------------------------------------------

int10_write_char:

            push    ax bx cx dx si di ds es

            ; Используемые адреса ds/es
            push    ax
            mov     ds, [cs:seg_40]
            mov     es, [cs:seg_b800]

            ; Текущее положение курсора
            mov     bx, word [curpos_x-bios_data]
            mov     al, bh
            mov     ah, 80
            mul     ah
            mov     bh, 0
            add     ax, bx
            add     ax, ax      ; ax=2*(80*bh+bl)
            mov     di, ax
            pop     ax

            ; Управляющие символы
            mov     bx, word [curpos_x-bios_data]
            cmp     al, 0x0A
            je      .LF         ; Y++
            cmp     al, 0x0D
            je      .CR         ; X=0
            cmp     al, 0x07
            je      .next1

            ; Backspace
            cmp     al, 0x08
            jne     .psym
            and     bl, bl      ; Проверить что X=0
            je      .next1      ; Если да, то пропустить
            dec     bl          ; Если нет, то X--
            jmp     .next1

.psym:      stosb               ; Печать символа
            inc     bl          ; Следующий символ
            cmp     bl, 80
            jb      .next1
            inc     bh          ; Y++
            jmp     .CR
.LF:        inc     bh          ; Y++
            jmp     .LFO
.CR:        mov     bl, 0
.LFO:       cmp     bh, 25
            jb      .next1
            mov     bh, 24

            ; Скроллинг экрана наверх
            push    bx
            mov     ax, 0601h
            mov     bh, 07h
            mov     cx, 0000h
            mov     dx, 184Fh
            int     10h
            pop     bx

            ; Установка нового положения курсора
.next1:     mov     word [curpos_x-bios_data], bx
            mov     dx, bx
            mov     ah, 2
            int     10h

            pop     es ds di si dx cx bx ax
            iret

; ----------------------------------------------------------------------
; Получение видеорежима 0Fh
; ----------------------------------------------------------------------

int10_get_vm:

            push    ds
            mov     ds, [cs:seg_40]
            mov     ah, 80
            mov     al, [es:vidmode-bios_data]
            mov     bh, 0
            pop     es
            iret
