; ----------------------------------------------------------------------
; МОДУЛЬ SD-КАРТЫ
; ----------------------------------------------------------------------

; sd_type (0=none,1,2,3=sdhc)

SD_LBA:     dd      0
SD_CMD_ARG: dw      0, 0
SD_TYPE:    db      0

sd_wait:    push    ax
@@:         in      al, $fe
            add     al, al
            jc      @b
            pop     ax
            ret

; Отсылка 80 тактов
sd_enable:  call    sd_wait
            mov     al, 0
            call    sd_cmd
            ret

            ; Отсылка команды
sd_cmd:     out     $fe, al
            call    sd_wait
            ret

            ; Отсылка данных
sd_put:     call    sd_wait
            out     $ff, al
            mov     al, 1
            out     $fe, al
            call    sd_wait
            ret

            ; Прием данных
sd_get:     mov     al, $ff
            call    sd_put
            in      al, $ff
            ret

; ----------------------------------------------------------------------
; Отсылка команды AH и [sd_arg] к SD
; ----------------------------------------------------------------------

sd_command:

            ; for 0..65535: if (get() == FF) break;
            mov     cx, 65535
@@:         call    sd_get
            cmp     al, 0xff
            loopnz  @b
            and     cx, cx
            je      .error

            ; Отсылка команды к SD
            mov     al, ah
            or      al, $40
            call    sd_put

            ; Отослать 32-х битную команду
            mov     bx, SD_CMD_ARG+4
            mov     cx, 4
@@:         dec     bx
            mov     al, [cs:bx]
            call    sd_put
            loop    @b

            ; Отправка CRC
            mov     al, 0xff
            cmp     ah, 0
            jne     .c1
            mov     al, 0x95        ; CMD0 with arg 0
            jmp     .c2
.c1:        cmp     ah, 8
            jne     .c2
            mov     al, 0x87        ; CMD8 with arg 0x1AA
.c2:        call    sd_put

            ; Ожидать снятия флага BUSY
            mov     cx, 256
@@:         call    sd_get
            test    al, $80
            loopnz  @b
            and     cx, cx
            je      .error

            ; Возвращает AL
            clc
            ret
.error:     stc
            ret

; ----------------------------------------------------------------------
sd_acmd:    push    cx
            push    ax
            push    word [cs:bx+2]
            push    word [cs:bx]

            ; command(SD_CMD55, 0);
            xor     ax, ax
            mov     [cs:bx],  ax
            mov     [cs:bx+2], ax
            mov     ah, 55
            call    sd_command

            ; command(cmd, arg);
            pop     word [cs:bx]
            pop     word [cs:bx+2]
            pop     ax
            call    sd_command
            pop     cx
            ret

; ----------------------------------------------------------------------
; Инициализация устройства, DS должен быть равен 0
; ----------------------------------------------------------------------

sd_init:    mov     bx, SD_CMD_ARG
            mov     al, 2
            call    sd_cmd          ; ChipEnable

            ; SDCommand(CMD0, 0)
            xor     ax, ax
            mov     [cs:bx+2], ax
            mov     [cs:bx],   ax
            mov     [cs:SD_TYPE], al
            call    sd_command
            jc      .error          ; Возможно тайм-аут
            cmp     al, 1
            jne     .error          ; Неправильный ответ

            ; Определить тип карты (SD1)
            mov     [cs:SD_CMD_ARG],   word 0x01AA
            mov     ah, 8
            call    sd_command
            jc      .error
            test    al, R1_ILLEGAL_COMMAND
            je      .checksd2

            ; Есть illegal-бит, это карта SD1
            mov     [cs:SD_TYPE], byte SD_CARD_TYPE_SD1
            jmp     .init1

.checksd2:  ; Прочесть 4 байта, последний будет важный
            call    sd_get
            call    sd_get
            call    sd_get
            call    sd_get
            cmp     al, $AA
            jne     .error
            mov     [cs:SD_TYPE], byte SD_CARD_TYPE_SD2
            mov     [cs:bx+2], word 0x4000

.init1:     ; Инициализация карты и отправка кода поддержки (SDHC если SD2)
            ; Отсылка ACMD = 0x29. Отсылать и ждать, пока не придет корректный ответ
            mov     cx, 8192
@@:         mov     ah, 0x29
            call    sd_acmd
            cmp     al, R1_READY_STATE
            loopnz  @b
            and     cx, cx
            je      .error

            ; Если SD2, читать OCR регистр для проверки SDHC карты
            cmp     [cs:SD_TYPE], byte SD_CARD_TYPE_SD2
            jne     .exit

            ; Проверка наличия байта в ответе CMD58 (должно быть 0)
            xor     ax, ax
            mov     [cs:bx], ax
            mov     [cs:bx+2], ax
            mov     ah, 0x3A
            call    sd_command
            and     al, al
            jne     .error

            ; Прочесть ответ от карты и определить тип (SDHC если есть)
            call    sd_get
            cmp     al, 0xc0
            jne     @f
            ; Если ответ C0h это SDHC
            mov     [cs:SD_TYPE], byte SD_CARD_TYPE_SD3
@@:         call    sd_get
            call    sd_get
            call    sd_get

            ; Ошибок не было CF=0
.exit:      clc
            ret

            ; Появились ошибки CF=1
.error:     stc
            ret

; ----------------------------------------------------------------------
; Чтение сектора в ES:DI; LBA находится в SD_LBA (dword)
; ----------------------------------------------------------------------

sd_read:    push    ds
            xor     ax, ax
            mov     ds, ax

            ; В случае истечения таймаута ожидания
            in      al, $fe
            test    al, $40
            je      @f

            call    sd_enable
            call    sd_init

            ; Запрос сектора
@@:         mov     ax, [cs:SD_LBA]
            mov     [cs:SD_CMD_ARG], ax
            mov     ax, [cs:SD_LBA+2]
            mov     [cs:SD_CMD_ARG+2], ax
            mov     ah, 0x11
            call    sd_command
            and     al, al
            jne     .error

            ; Ожидание ответа от SD
            mov     cx, 8192
@@:         call    sd_get
            cmp     al, 0xff
            loopz   @b
            and     cx, cx
            je      .error          ; Таймаут ответа
            cmp     al, 0xFE
            jne     .error          ; Не тот ответ

            ; Чтение сектора
            mov     cx, 512
@@:         call    sd_get
            stosb
            loop    @b

.done:      clc
            jmp     .exit
.error:     stc
.exit:      mov     al, 3           ; Отключение чипа
            call    sd_cmd
            pop     ds
            ret
; ----------------------------------------------------------------------
