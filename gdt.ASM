use16
org 0x7c00
start:

; CLEAN SCREEN
mov ax,3
int 10h

; INIT GDTR REGISTER
mov eax, GDT_START
shl eax, 16
lea ebx, [(GDT_END-GDT_START) - 1]
or eax, ebx
mov [GDTR], eax
lgdt fword [GDTR]

; SWITCH TO PROTECTED MODE
mov eax, cr0
or al, 1
mov cr0, eax


; EXECUTE CODE OF 1st SELECTOR
jmp 8:0

use32
; FROM HERE AND BELOW CODE EXECUTED IN PROTECTED MODE
PROTECTED_MODE: nop

; INIT DS WITH 1ST SELECTOR
mov ax, 0x8
mov ds, ax
lea esi, [msg_start - PROTECTED_MODE]

; INIT ES WITH 2ND SELECTOR (VIDEO MEMORY)
mov ax, 0x10
xor edi, edi
mov es, ax

; COPY MESSAGE TO VIDEO MEMORY
lea ecx, [msg_end - msg_start]
xor eax, eax
rep movsb
xchg bx, bx
ATR EQU 0x30 ; green

msg_start db 'H', ATR, 'i', ATR, ' ', ATR
            db 'f', ATR, 'r', ATR, 'o', ATR, 'm', ATR, ' ', ATR
            db 'p', ATR, 'r', ATR, 'o', ATR, 't', ATR, 'e', ATR, 'c', ATR, 't', ATR, 'e', ATR, 'd', ATR, ' ', ATR
            db 'm', ATR, 'o', ATR, 'd', ATR, 'e', ATR, '!', ATR
msg_end:

align 8
GDTR dd ?
; GLOBAL DESCRIPTOR TABLE
GDT_START:
        ;NULL (DESCRIPTOR 0)
        dq 0    

        ;CODE (DESCRIPTOR 1 => SELECTOR 1<<3 = 8)
        dw 0x0fff ;size
        dw PROTECTED_MODE
        dw 0x9a00
        dw 0x0040

        ;VIDEO MEM. (DESCRIPTOR 2 => SELECTOR 2<<3 = 0x18_
        dw 0xffff
        dw 0x8000   ; 0x8000 |
                    ;        | => mixed to 0x0b8000 - address of VIDEO MEM
        dw 0x920b   ; 0x0b   |
        dw 0x0040
GDT_END:
db 510-($-start) dup(0), 0x55, 0xAA
