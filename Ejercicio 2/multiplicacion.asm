section .data
    prompt1 db 'Ingrese el primer numero (0-255): '
    prompt1_len equ $ - prompt1
    prompt2 db 'Ingrese el segundo numero (0-255): '
    prompt2_len equ $ - prompt2
    
    operation_msg db 'Operacion: '
    operation_len equ $ - operation_msg
    
    error_msg db 'Error: Numero fuera de rango (0-255) o invalido!', 10
    error_len equ $ - error_msg
    
    multiply_sign db ' x '
    equal_sign db ' = '
    newline db 10

section .bss
    input resb 10
    output resb 10
    num1 resb 1         ; Registro de 8 bits
    num2 resb 1         ; Registro de 8 bits
    result resw 1       ; Resultado de 16 bits (8x8 = máximo 16 bits)

section .text
    global _start

_start:
    ; Solicitar primer número
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall
    
    ; Leer primer número
    call read_number_8bit
    jc input_error
    mov [num1], al      ; Guardar en registro de 8 bits
    
    ; Solicitar segundo número
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall
    
    ; Leer segundo número
    call read_number_8bit
    jc input_error
    mov [num2], al      ; Guardar en registro de 8 bits
    
    ; Realizar la multiplicación usando registros de 8 bits
    mov al, [num1]      ; Cargar primer número en AL (8 bits)
    mov bl, [num2]      ; Cargar segundo número en BL (8 bits)
    mul bl              ; AL * BL = AX (resultado en AX de 16 bits)
    mov [result], ax    ; Guardar resultado
    
    ; Mostrar operación
    mov rax, 1
    mov rdi, 1
    mov rsi, operation_msg
    mov rdx, operation_len
    syscall
    
    ; Mostrar num1
    mov al, [num1]
    call print_number_8bit
    
    ; Mostrar " x "
    mov rax, 1
    mov rdi, 1
    mov rsi, multiply_sign
    mov rdx, 3
    syscall
    
    ; Mostrar num2
    mov al, [num2]
    call print_number_8bit
    
    ; Mostrar " = "
    mov rax, 1
    mov rdi, 1
    mov rsi, equal_sign
    mov rdx, 3
    syscall
    
    ; Mostrar resultado
    mov ax, [result]
    call print_number_16bit
    
    ; Nueva línea
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    
    jmp exit_program

input_error:
    ; Mostrar mensaje de error
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall

exit_program:
    ; Salir
    mov rax, 60
    xor rdi, rdi
    syscall

; Leer número de 8 bits (0-255) desde entrada
; Devuelve resultado en AL, establece CF si hay error
read_number_8bit:
    push rbx
    push rcx
    push rdx
    push rsi
    
    ; Leer entrada
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 10
    syscall
    
    ; Verificar si se leyó algo
    cmp rax, 1
    jle read_error_8bit
    
    mov rsi, input
    xor eax, eax        ; Limpiar EAX
    mov rbx, 10
    xor rcx, rcx
    mov r8, 0           ; Contador de dígitos
    
convert_loop_8bit:
    mov cl, [rsi]
    cmp cl, 10          ; Newline
    je convert_done_8bit
    cmp cl, 0           ; Null terminator
    je convert_done_8bit
    cmp cl, '0'
    jl read_error_8bit
    cmp cl, '9'
    jg read_error_8bit
    
    sub cl, '0'
    mul bl              ; AL * 10
    jc read_error_8bit  ; Overflow en 8 bits
    add al, cl
    jc read_error_8bit  ; Overflow en 8 bits
    
    ; Verificar que no exceda 255
    cmp ax, 255
    jg read_error_8bit
    
    inc rsi
    inc r8
    jmp convert_loop_8bit

convert_done_8bit:
    ; Verificar si se leyó al menos un dígito
    cmp r8, 0
    je read_error_8bit
    
    clc                 ; Sin error
    jmp read_exit_8bit

read_error_8bit:
    stc                 ; Error

read_exit_8bit:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Imprimir número de 8 bits en AL
print_number_8bit:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    ; Extender AL a AX para usar la rutina de división
    movzx ax, al        ; Zero-extend AL a AX
    
    mov rbx, 10
    xor rcx, rcx
    mov rsi, output
    add rsi, 9
    
    ; Caso especial para 0
    cmp ax, 0
    jne convert_digits_8bit
    mov byte [output], '0'
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall
    jmp print_done_8bit

convert_digits_8bit:
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    inc rcx
    test ax, ax
    jne convert_digits_8bit
    
    ; Imprimir el número
    inc rsi
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall

print_done_8bit:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Imprimir número de 16 bits en AX (para el resultado)
print_number_16bit:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rbx, 10
    xor rcx, rcx
    mov rsi, output
    add rsi, 9
    
    ; Caso especial para 0
    cmp ax, 0
    jne convert_digits_16bit
    mov byte [output], '0'
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall
    jmp print_done_16bit

convert_digits_16bit:
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rsi], dl
    dec rsi
    inc rcx
    test ax, ax
    jne convert_digits_16bit
    
    ; Imprimir el número
    inc rsi
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall

print_done_16bit:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret