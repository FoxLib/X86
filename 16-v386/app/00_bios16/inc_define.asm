
; SD CARD
;SD_CMD_ARG              equ     $4AC
;SD_TYPE                 equ     $4B0    ; 0=none,1,2,3=sdhc
;SD_LBA                  equ     $4B1

; Константы для SD-обработчика
R1_READY_STATE          equ     0x00
R1_ILLEGAL_COMMAND      equ     0x04
SD_CARD_TYPE_NONE       equ     0x00
SD_CARD_TYPE_SD1        equ     0x01
SD_CARD_TYPE_SD2        equ     0x02
SD_CARD_TYPE_SD3        equ     0x03

macro   com_load _address {

        mov     ax, cs
        mov     ds, ax
        mov     ax, _address shr 4
        mov     es, ax
        mov     si, unit
        mov     di, $0000
        mov     cx, usize
        rep     movsb
}

; Передача управлению бут-сектору
macro   boot_start {

        com_load $7C00
        xor     ax, ax
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        xor     ax, ax
        mov     dl, 0x80
        mov     sp, $7C00
        sti
        jmp     0x0000 : 0x7C00

}

; Симуляция загрузки программы DOS
macro   dos_start {

        com_load $0500
        mov     ax, $0040
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, $FFFE
        mov     si, $100
        xor     di, di
        sti
        jmp     0x0040 : 0x0100
}
