section .bss
    global key
    key   resb 1        ; tecla final
    dummy resb 1        ; descarta '['

section .text
    global read_input

read_input:
    ; lê 1 byte
    mov rax, 0
    mov rdi, 0
    mov rsi, key
    mov rdx, 1
    syscall

    ; se não for ESC, acabou
    cmp byte [key], 27
    jne .done

    ; sequência de seta → lê '['
    mov rax, 0
    mov rdi, 0
    mov rsi, dummy
    mov rdx, 1
    syscall

    ; lê o código final (A,B,C,D)
    mov rax, 0
    mov rdi, 0
    mov rsi, key
    mov rdx, 1
    syscall

    ; converte seta → wasd
    mov al, [key]
    cmp al, 'A'
    je .to_w
    cmp al, 'B'
    je .to_s
    cmp al, 'C'
    je .to_d
    cmp al, 'D'
    je .to_a
    jmp .done

.to_w: mov byte [key], 'w'
       jmp .done
.to_s: mov byte [key], 's'
       jmp .done
.to_d: mov byte [key], 'd'
       jmp .done
.to_a: mov byte [key], 'a'

.done:
    ret
