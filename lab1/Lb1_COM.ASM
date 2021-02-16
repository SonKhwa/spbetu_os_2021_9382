TESTPC SEGMENT
 ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
 ORG 100H
START: JMP BEGIN
; ДАННЫЕ ТИП PC
type_of db 'Type of PC: $'
pc db 'PC',0DH,0AH,'$'
pc_xt db 'PC/XT',0DH,0AH,'$'
at db 'AT',0DH,0AH,'$'
ps2_model_30 db 'PS2 model 30',0DH,0AH,'$'
ps2_model_80 db 'PS2 model 80',0DH,0AH,'$'
pcjr db 'PCjr',0DH,0AH,'$'
pc_convertible db 'PC Convertible',0DH,0AH,'$'
; ДАННЫЕ ВЕРСИЯ PC
version_pc db 'Version of MS DOS:  .  ',0DH,0AH,'$'
serial_number_oem db 'Serial number of OEM:   $'
serial_number_of_user db 'Serial number of user:         $'
at_end db 0DH,0AH,'$'

;ПРОЦЕДУРЫ
;-----------------------------------------------------
TETR_TO_HEX PROC near
 and AL,0Fh
 cmp AL,09
 jbe NEXT
 add AL,07
NEXT: add AL,30h
 ret
TETR_TO_HEX ENDP
;-------------------------------
BYTE_TO_HEX PROC near
; байт в AL переводится в два символа шестн. числа в AX
 push CX
 mov AH,AL
 call TETR_TO_HEX
 xchg AL,AH
 mov CL,4
 shr AL,CL
 call TETR_TO_HEX ;в AL старшая цифра
 pop CX ;в AH младшая
 ret
BYTE_TO_HEX ENDP
;-------------------------------
WRD_TO_HEX PROC near
;перевод в 16 с/с 16-ти разрядного числа
; в AX - число, DI - адрес последнего символа
 push BX
 mov BH,AH
 call BYTE_TO_HEX
 mov [DI],AH
 dec DI
 mov [DI],AL
 dec DI
 mov AL,BH
 call BYTE_TO_HEX
 mov [DI],AH
 dec DI
 mov [DI],AL
 pop BX
 ret
WRD_TO_HEX ENDP
;--------------------------------------------------
BYTE_TO_DEC PROC near
; перевод в 10с/с, SI - адрес поля младшей цифры
 push CX
 push DX
 xor AH,AH
 xor DX,DX
 mov CX,10
loop_bd: 
 div CX
 or DL,30h
 mov [SI],DL
 dec SI
 xor DX,DX
 cmp AX,10
 jae loop_bd
 cmp AL,00h
 je end_l
 or AL,30h
 mov [SI],AL
end_l: 
 pop DX
 pop CX
 ret
BYTE_TO_DEC ENDP
;-------------------------------
; КОД
print_string proc near
    mov ah, 09h
    int 21h
    ret
print_string endp

print_type_of_PC proc near
    mov dx, offset type_of
    call print_string
    mov ax, 0F000h
    mov es, ax
    mov al, es:[0FFFEh]
    cmp al, 0FFh
    je print1
    cmp al, 0FEh
    je print2
    cmp al, 0FBh
    je print2
    cmp al, 0FCh
    je print3
    cmp al, 0FAh
    je print4
    cmp al, 0F8h
    je print5
    cmp al, 0FDh
    je print6
    cmp al, 0F9h
    je print7

print1:
    mov dx, offset pc
    jmp to_end
    
print2:
    mov dx, offset pc_xt 
    jmp to_end 

print3:
    mov dx, offset at
    jmp to_end 

print4:
    mov dx, offset ps2_model_30 
    jmp to_end 

print5:
    mov dx, offset ps2_model_80 
    jmp to_end 

print6:
    mov dx, offset pcjr 
    jmp to_end 

print7:
    mov dx, offset pc_convertible

to_end:
    call print_string
    ret
print_type_of_PC endp

print_version_of_PC proc near
    mov ah, 30h
    int 21h

    push ax
    mov si, offset version_pc
    add si, 19
    call BYTE_TO_DEC
    pop ax
    mov al, ah
    add si, 3
    call BYTE_TO_DEC
    mov dx, offset version_pc
    call print_string

    mov si, offset serial_number_oem
    add si, 22
    mov al, bh
    call BYTE_TO_DEC
    mov dx, offset serial_number_oem
    call print_string
    mov dx, offset at_end
    call print_string

    mov di, offset serial_number_of_user
    add di, 28
    mov ax, cx
    call WRD_TO_HEX
    mov al, bl
    call BYTE_TO_HEX
    sub di, 2
    mov [di], ax
    mov dx, offset serial_number_of_user
    call print_string
    mov dx, offset at_end
    call print_string
    ret
print_version_of_PC endp

BEGIN:
; . . . . . . . . . . . .
    call print_type_of_PC
    call print_version_of_PC
; . . . . . . . . . . . .
; Выход в DOS
 xor AL,AL
 mov AH,4Ch
 int 21H
TESTPC ENDS
 END START ;конец модуля, START - точка входа