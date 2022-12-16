
        org     100h

; Макрос для проверки валидности
; ----------------------------------------------------------------------
macro   assert  pos, loc, eq, flag {
        push    dx
        pushf
        cmp     loc, eq
        pop     dx
        mov     [es: 2*pos], word 0x4F40 + pos  ; Результат
        jne     @f
        and     dx, 0x8FF
        cmp     dx, flag                        ; Флаг
        jne     @f
        mov     [es: 2*pos], word 0x202E        ; ERROR
@@:     pop     dx
}
; ----------------------------------------------------------------------

unit_test_1:

        mov     ax, $B800
        mov     es, ax
        mov     ax, $1000
        mov     ds, ax
        mov     ds, ax
        add     ax, $0010
        mov     ss, ax      ; ss = ds + 10h

        ; Первичный тест на работоспособность видеопамяти
        mov     ax, 0x202E
        mov     [es: 0], ax

        ; Заполнение памяти нулями
        xor     bx, bx
@@:     mov     [bx], byte 0
        inc     bx
        jne     @b
        xor     ax, ax
@@:     add     ax, [bx]
        add     bx, 2
        jne     @b

        ; Проверка, что память нулевая
        cmp     ax, 0
        mov     [es: 2], word 0x202E        ; OK
        je      @f
        mov     [es: 2], word 0x4F2E        ; ERROR

        ; Последовательный тест на работу с данными
@@:     mov     bx, $2135
        mov     bp, $1235
        mov     si, $AFD3
        mov     di, $7344

        ; Очистить флаги
        xor     ax, ax
        push    ax
        popf

        ; ==========================================================
        ; 00-03 ADD rm, r8
        ; Тестирование работы разных режимов считывания modrm
        ; ==========================================================

        mov     [bx+si], byte $AF
        mov     al, $32
        add     [bx+si], al
        assert  1, [$D108], byte $E1, $096      ; "A"

        add     al, [bx+si]
        assert  2, al, byte $13, $003           ; "B" ZF

        mov     [bx+di], byte $12
        mov     al, $EE
        add     [bx+di], al
        assert  3, [$9479], byte $00, $057      ; "C" OF

        mov     ah, $7F
        mov     al, $12
        mov     [bp+si], ah
        add     [bp+si], al
        add     ah, al
        assert  4, [$c208+$100], byte $91, $892 ; "D" SF

        mov     [bp+di], byte $11
        mov     al, $81
        add     [bp+di], al
        assert  5, [$8579+$100], byte $92, $082 ; "E" AF

        mov     [si], byte $5A
        mov     al, $1A
        add     [si], al
        assert  6, [$AFD3], byte $74, $016      ; "F" PF

        mov     [di], byte $DA
        mov     al, $D3
        add     [di], al
        assert  7, [$7344], byte $AD, $083      ; "G"

        add     [di], al
        assert  8, [$7344], byte $80, $093      ; "H" CF

        mov     al, $FF
        mov     [bx], byte $FF
        add     [bx], al
        assert  9, [$2135], byte $FE, $093      ; "I"

        ; 16 bit
        mov     ax, $2634
        mov     [bx+di+4], word $6234
        add     [bx+di+4], ax
        assert  10, [$947D], word $8868, $882   ; "J"

        mov     ax, $8ABF
        mov     [bx+si-1], word $123A
        add     [bx+si-1], ax
        assert  11, [$D107], word $9CF9, $096   ; "K"

        mov     ax, $6334
        mov     [bx+si+325], word $AABB
        add     [bx+si+325], ax
        assert  12, [$D24D], word $0DEF, $003   ; "L"

        mov     ax, $5A4B
        mov     [bx+di-2345], word $BAFA
        add     [bx+di-2345], ax
        assert  13, [$8B50], word $1545, $013   ; "M"

        mov     ax, $4342
        mov     [bp+1], word $5232
        add     [bp+1], ax                      ; "N"
        assert  14, [$1236+$100], word $9574, $886

        mov     ax, $8234
        mov     bp, $AFBA
        add     bp, ax                          ; "O"
        assert  15, bp, word $31EE, $807

        mov     ax, $1235
        mov     [bp-32768], word $623F
        add     ax, [bp-32768]                  ; "P"
        assert  16, [$B1EE+$100], word $623F, $016

        ; ==========================================================
        ; 04-05 ADD Ac, imm
        ; SUB | ADC | SBC | AND | XOR | OR | CMP imm8/16
        ; ==========================================================

        mov     ax, $1274
        add     al, $FA
        assert  17, ax, $126E, $003             ; "Q"
        add     ax, $FAFA
        assert  18, ax, $0D68, $013             ; "R"
        add     al, $EE
        assert  19, ax, $0D56, $017             ; "S"

        sub     al, $AF
        assert  20, ax, $0DA7, $893             ; "T"
        sub     ax, $3123
        assert  21, ax, $DC84, $087             ; "U"
        sub     al, $FE
        assert  22, ax, $DC86, $093             ; "V"

        clc
        adc     al, $DA
        assert  23, ax, $DC60, $817             ; "W"
        stc
        adc     al, $32
        assert  24, ax, $DC93, $886             ; "X"
        adc     ax, $F78F
        assert  25, ax, $D422, $097             ; "Y"
        adc     al, $FF
        assert  26, ax, $D421, $017             ; "Z"

        jmp     $
