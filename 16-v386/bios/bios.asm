
        org     0

        include "inc_define.asm"

bios_start:

        cli
        cld
        xor     ax, ax
        mov     es, ax
        mov     ds, ax
        mov     ss, ax
        mov     sp, $400
        call    ivtset
        mov     ax, $0003
        int     10h

        dos_start

; ----------------------------------------------------------------------
unit:
;       file    "unit/doom.bin"         ; boot_start
;       file    "unit/fbird.com"        ; dos_start
;       file    "unit/pillman.com"      ; dos_start
;       file    "unit/invaders.com"     ; dos_start
;       file    "unit/rogue.com"        ; dos_start (ошибки)
;       file    "unit/railways.com"     ; dos_start (ошибки)
;       file    "unit/basic.bin"        ; boot_start
        file    "../app/01_game/main.com"

usize   = $ - unit
; ----------------------------------------------------------------------
        include "inc_biosconfig.asm"
        include "inc_disk.asm"
        include "inc_video.asm"
        include "inc_stdlib.asm"
        include "inc_keyboard.asm"
        include "inc_interrupts.asm"
; ----------------------------------------------------------------------

        times   32768-16-$ db 0
        jmp     far 0F000h : 0
        db      '27/04/22'
        db      0x00, 0xFE, 0x00
