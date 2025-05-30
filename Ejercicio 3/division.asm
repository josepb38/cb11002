section .data
    prompt1 db 'Ingrese el dividendo (numero a dividir): '
    prompt1_len equ $ - prompt1
    prompt2 db 'Ingrese el divisor (numero por el cual dividir): '
    prompt2_len equ $ - prompt2
    
    operation_msg db 'Operacion: '
    operation_len equ $ - operation_msg
    
    remainder_msg db ', Residuo: '
    remainder_len equ $ - remainder_msg
    
    error_msg db 'Error: Numero invalido o fuera de rango!', 10
    error_len equ $ - error_msg
    
    zero_error_msg db 'Error: No se puede dividir por cero!', 10
    zero_error_len equ $ - zero_error_msg
    
    divide_sign db ' / '
    equal_sign db ' = '
    newline db 10

section .bss
    input resb 15
    output resb 15
    num1 resd 1         ; Dividendo (32 bits)
    num2 resd 1         ; Divisor (32 bits)
    quotient resd 1     ; Cociente (32 bits)
    remainder resd 1    ; Residuo (32 bits)

section .text
    global _start

_start:
    ; Solicitar dividendo
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall
    
    ; Leer dividendo
    call read_number_32bit
    jc input_error
    mov [num1], eax     ; Guardar en registro de 32 bits
    
    ; Solicitar divisor
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall
    
    ; Leer divisor
    call read_number_32bit
    jc input_error
    cmp eax, 0          ; Verificar división por cero
    je zero_error
    mov [num2], eax     ; Guardar en registro de 32 bits
    
    ; Realizar la división usando registros de 32 bits
    mov eax, [num1]     ; Cargar dividendo en EAX (32 bits)
    xor edx, edx        ; Limpiar EDX (parte alta del dividendo)
    mov ebx, [num2]     ; Cargar divisor en EBX (32 bits)
    div ebx             ; EAX / EBX = EAX (cociente), EDX (residuo)
    
    mov [quotient], eax ; Guardar cociente
    mov [remainder], edx ; Guardar residuo
    
    ; Mostrar operación
    mov rax, 1
    mov rdi, 1
    mov rsi, operation_msg
    mov rdx, operation_len
    syscall
    
    ; Mostrar dividendo
    mov eax, [num1]
    call print_number_32bit
    
    ; Mostrar " / "
    mov rax, 1
    mov rdi, 1
    mov rsi, divide_sign
    mov rdx, 3
    syscall
    
    ; Mostrar divisor
    mov eax, [num2]
    call print_number_32bit
    
    ; Mostrar " = "
    mov rax, 1
    mov rdi, 1
    mov rsi, equal_sign
    mov rdx, 3
    syscall
    
    ; Mostrar cociente
    mov eax, [quotient]
    call print_number_32bit
    
    ; Mostrar residuo si es diferente de cero
    mov eax, [remainder]
    cmp eax, 0
    je skip_remainder
    
    ; Mostrar mensaje de residuo
    mov rax, 1
    mov rdi, 1
    mov rsi, remainder_msg
    mov rdx, remainder_len
    syscall
    
    ; Mostrar valor del residuo
    mov eax, [remainder]
    call print_number_32bit

skip_remainder:
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
    jmp exit_program

zero_error:
    ; Mostrar mensaje de error por división por cero
    mov rax, 1
    mov rdi, 1
    mov rsi, zero_error_msg
    mov rdx, zero_error_len
    syscall

exit_program:
    ; Salir
    mov rax, 60
    xor rdi, rdi
    syscall

; Leer número de 32 bits desde entrada
; Devuelve resultado en EAX, establece CF si hay error
read_number_32bit:
    push rbx
    push rcx
    push rdx
    push rsi
    
    ; Leer entrada
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 15
    syscall
    
    ; Verificar si se leyó algo
    cmp rax, 1
    jle read_error_32bit
    
    mov rsi, input
    xor eax, eax        ; Limpiar EAX
    mov ebx, 10
    xor rcx, rcx
    mov r8, 0           ; Contador de dígitos
    
convert_loop_32bit:
    mov cl, [rsi]
    cmp cl, 10          ; Newline
    je convert_done_32bit
    cmp cl, 0           ; Null terminator
    je convert_done_32bit
    cmp cl, '0'
    jl read_error_32bit
    cmp cl, '9'
    jg read_error_32bit
    
    sub cl, '0'
    
    ; Verificar overflow antes de multiplicar
    cmp eax, 429496729  ; (2^32 - 1) / 10
    jg read_error_32bit
    
    mul ebx             ; EAX * 10
    jc read_error_32bit ; Overflow
    add eax, ecx
    jc read_error_32bit ; Overflow
    
    inc rsi
    inc r8
    jmp convert_loop_32bit

convert_done_32bit:
    ; Verificar si se leyó al menos un dígito
    cmp r8, 0
    je read_error_32bit
    
    clc                 ; Sin error
    jmp read_exit_32bit

read_error_32bit:
    stc                 ; Error

read_exit_32bit:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Imprimir número de 32 bits en EAX
print_number_32bit:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov ebx, 10
    xor rcx, rcx
    mov rsi, output
    add rsi, 14         ; Posición al final del buffer
    
    ; Caso especial para 0
    cmp eax, 0
    jne convert_digits_32bit
    mov byte [output], '0'
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall
    jmp print_done_32bit

convert_digits_32bit:
    xor edx, edx
    div ebx             ; EAX / 10 = EAX, EDX = residuo
    add dl, '0'         ; Convertir dígito a ASCII
    mov [rsi], dl
    dec rsi
    inc rcx
    test eax, eax
    jne convert_digits_32bit
    
    ; Imprimir el número
    inc rsi
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall

print_done_32bit:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret