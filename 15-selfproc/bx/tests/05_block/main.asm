
XRES    equ     640
YRES    equ     400

        call    fillall(3)
        call    window(75, 50, 320, 200, test1)
        hlt

test1:  db      "Windows 97 Rulezz Forever...",0

; ----------------------------------------------------------------------

        include "$(INC)/winda.asm"
        include "$(INC)/drawing.asm"
        include "$(INC)/print.asm"
fonts:  file    "$(INC)/font8x8.bin"
