
            ; Загрузка новой векторной таблицы; DS должен быть 0
ivtset:     mov     si, ivttable
            mov     ax, cs
            mov     ds, ax
            xor     di, di
            mov     cx, 32
@@:         lodsw
            stosw
            mov     ax, cs
            stosw
            loop    @b
            mov     si, bios_data
            mov     di, $400
            mov     cx, bda_end
            rep     movsb               ; Загрузка BDA
            ret
_dummy:     iret

; ----------------------------------------------------------------------
ivttable:

    dw      _dummy, _dummy, _dummy, _dummy ; 00 01 02 03
    dw      _dummy, _dummy, _dummy, _dummy ; 04 05 06 07
    dw      int_08, int_09, _dummy, _dummy ; 08 09 0A 0B
    dw      _dummy, _dummy, _dummy, _dummy ; 0C 0D 0E 0F
    dw      int_10, _dummy, _dummy, _dummy ; 10 11 12 13
    dw      _dummy, _dummy, int_16, _dummy ; 14 15 16 17
    dw      _dummy, _dummy, int_1a, _dummy ; 18 19 1A 1B
    dw      _dummy, _dummy, _dummy, _dummy ; 1C 1D 1E 1F


; ----------------------------------------------------------------------
; IRQ
; ----------------------------------------------------------------------

            ; Таймер
int_08:     push    ax ds
            mov     ds, [cs:seg_40]

            ; Инкрементировать таймер
            mov     ax, word [clk_dtimer-bios_data]
            add     ax, 1
            mov     word [clk_dtimer-bios_data], ax
            mov     ax, word [clk_dtimer-bios_data+2]
            adc     ax, 0
            mov     word [clk_dtimer-bios_data+2], ax

            ; Завершить прерывание
            mov     al, $20
            out     $20, al
            pop     ds ax
            iret

; ----------------------------------------------------------------------

            ; Видеосервис
int_10:     and     ah, ah
            je      int10_set_vm
            cmp     ah, 01h
            je      int10_set_cshape
            cmp     ah, 02h
            je      int10_set_cursor
            cmp     ah, 03h
            je      int10_get_cursor
            cmp     ah, 06h
            je      int10_scrollup

            ; 07h Scroll down window
            ; int10_scrolldown

            ; 08h Get character at cursor
            ; int10_charatcur

            ; 09h Write char and attribute
            ; int10_write_char_attrib

            cmp     ah, 0Eh
            je      int10_write_char
            cmp     ah, 0Fh
            je      int10_get_vm

            iret

; ----------------------------------------------------------------------

            ; Клавиатура
int_16:     cmp     ah, 0
            je      int16_kb_wait
            cmp     ah, 1
            je      int16_kb_checkkey
            cmp     ah, 2
            je      int16_kb_shiftflags
            iret

; ----------------------------------------------------------------------

            ; Специальные
int_1a:     cmp     ah, 0
            je      int1a_getsystime    ; Получение тиков с момента сброса
            cmp     ah, 2
            je      int1a_gettime       ; Получение RTC time
            cmp     ah, 4
            je      int1a_getdate       ; Получение RTC date
            cmp     ah, 0x0F
            je      int1a_init          ; Инициализация RTC
            iret

            ; Получение количества тиков -> CX:DX

int1a_getsystime:

            push    ds
            mov     ds, [cs:seg_40]
            mov     cx, word [clk_dtimer-bios_data+2]
            mov     dx, word [clk_dtimer-bios_data]
            pop     ds
            iret

int1a_gettime:
int1a_getdate:
int1a_init:
            iret
