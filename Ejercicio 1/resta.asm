section .data
    prompt1 db 'Ingrese el primer numero: ', 0
    prompt1_len equ $ - prompt1 - 1
    
    prompt2 db 'Ingrese el segundo numero: ', 0
    prompt2_len equ $ - prompt2 - 1
    
    prompt3 db 'Ingrese el tercer numero: ', 0
    prompt3_len equ $ - prompt3 - 1
    
    operation_msg db 'Operacion: ', 0
    operation_len equ $ - operation_msg - 1
    
    minus_sign db ' - ', 0
    equal_sign db ' = ', 0
    newline db 10, 0
    error_msg db 'Error: Numero fuera de rango (-32768 a 32767)', 10, 0
    error_len equ $ - error_msg - 1

section .bss
    input resb 10
    output resb 12
    num1 resw 1
    num2 resw 1
    num3 resw 1
    result resw 1

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
    call read_number
    cmp rdx, 1
    je error_exit
    mov [num1], ax

    ; Solicitar segundo número
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall
    
    ; Leer segundo número
    call read_number
    cmp rdx, 1
    je error_exit
    mov [num2], ax

    ; Solicitar tercer número
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt3
    mov rdx, prompt3_len
    syscall
    
    ; Leer tercer número
    call read_number
    cmp rdx, 1
    je error_exit
    mov [num3], ax

    ; Realizar la resta: num1 - num2 - num3 (usando registros de 16 bits)
    mov ax, [num1]
    sub ax, [num2]
    sub ax, [num3]
    mov [result], ax

    ; Mostrar operación
    mov rax, 1
    mov rdi, 1
    mov rsi, operation_msg
    mov rdx, operation_len
    syscall

    ; Mostrar num1
    mov ax, [num1]
    call print_number

    ; Mostrar " - "
    mov rax, 1
    mov rdi, 1
    mov rsi, minus_sign
    mov rdx, 3
    syscall

    ; Mostrar num2
    mov ax, [num2]
    call print_number

    ; Mostrar " - "
    mov rax, 1
    mov rdi, 1
    mov rsi, minus_sign
    mov rdx, 3
    syscall

    ; Mostrar num3
    mov ax, [num3]
    call print_number

    ; Mostrar " = "
    mov rax, 1
    mov rdi, 1
    mov rsi, equal_sign
    mov rdx, 3
    syscall

    ; Mostrar resultado
    mov ax, [result]
    call print_number

    ; Nueva línea
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Salir exitosamente
    mov rax, 60
    xor rdi, rdi
    syscall

error_exit:
    ; Mostrar mensaje de error
    mov rax, 1
    mov rdi, 1
    mov rsi, error_msg
    mov rdx, error_len
    syscall
    
    ; Salir con código de error
    mov rax, 60
    mov rdi, 1
    syscall

; Leer número desde entrada y convertirlo (devuelve resultado en AX, error en RDX)
read_number:
    push rbx
    push rcx
    push rsi
    
    ; Leer entrada
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 10
    syscall
    
    ; Inicializar variables
    mov rsi, input
    xor rax, rax         ; Resultado
    mov rbx, 10          ; Base
    xor rcx, rcx         ; Carácter temporal
    xor rdx, rdx         ; Flag de error (0 = OK, 1 = Error)
    mov r8, 0            ; Flag para número negativo
    
    ; Verificar si es número negativo
    mov cl, [rsi]
    cmp cl, '-'
    jne convert_loop
    inc rsi              ; Saltar el signo negativo
    mov r8, 1            ; Marcar como negativo

convert_loop:
    mov cl, [rsi]
    cmp cl, 10           ; Nueva línea
    je convert_done
    cmp cl, 0            ; Fin de cadena
    je convert_done
    cmp cl, '0'
    jl invalid_input
    cmp cl, '9'
    jg invalid_input
    
    ; Verificar overflow antes de multiplicar
    cmp rax, 3276        ; 32767 / 10
    jg overflow_check
    
    sub cl, '0'
    mul rbx              ; RAX = RAX * 10
    add ax, cx           ; Sumar dígito (solo usar AX para mantener 16 bits)
    
    ; Verificar si excede el rango de 16 bits
    cmp rax, 32767
    jg invalid_input
    
    inc rsi
    jmp convert_loop

overflow_check:
    ; Si ya es >= 3276, verificar si el siguiente dígito causa overflow
    sub cl, '0'
    cmp cl, 7
    jg invalid_input
    mul rbx
    add ax, cx
    inc rsi
    jmp convert_loop

convert_done:
    ; Verificar si era número negativo
    cmp r8, 1
    jne positive_done
    neg ax               ; Hacer negativo
    cmp ax, -32768
    jl invalid_input

positive_done:
    xor rdx, rdx         ; Sin error
    jmp read_done

invalid_input:
    mov rdx, 1           ; Marcar error

read_done:
    pop rsi
    pop rcx
    pop rbx
    ret

; Imprimir número de 16 bits en AX
print_number:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    ; Verificar si es negativo
    test ax, ax
    jns positive_number
    
    ; Imprimir signo negativo
    push rax
    mov rax, 1
    mov rdi, 1
    mov byte [output], '-'
    mov rsi, output
    mov rdx, 1
    syscall
    pop rax
    neg ax

positive_number:
    mov rbx, 10
    xor rcx, rcx         ; Contador de dígitos
    mov rsi, output
    add rsi, 11          ; Apuntar al final del buffer
    
    ; Caso especial para 0
    cmp ax, 0
    jne convert_digits
    mov byte [output], '0'
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall
    jmp print_done

convert_digits:
    xor rdx, rdx
    div bx               ; AX = AX / 10, DX = AX % 10
    add dl, '0'          ; Convertir a ASCII
    mov [rsi], dl
    dec rsi
    inc rcx              ; Incrementar contador
    test ax, ax
    jne convert_digits
    
    ; Imprimir los dígitos
    inc rsi              ; Volver al primer dígito
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall

print_done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret