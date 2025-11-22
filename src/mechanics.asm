section .data
    level_1_name db "level1.txt", 0
    level_2_name db "level2.txt", 0
    level_3_name db "level3.txt", 0  

section .bss
    buffer resb 1

section .text
    global load_level, try_player_move, is_wall

    extern map, current_level, active_enemies
    extern player_x, player_y, player_hp, steps
    extern enemies_x, enemies_y, enemies_hp
    extern spawn_single_enemy, respawn_all_enemies

; --- Carrega mapa ---
load_level:
    mov al, [current_level]
    cmp al, 1
    je .l1
    cmp al, 2
    je .l2
    cmp al, 3
    je .l3
    ret

.l1:
    mov qword [active_enemies], 1
    mov rdi, level_1_name
    jmp .do_load
.l2:
    mov qword [active_enemies], 3
    mov rdi, level_2_name
    jmp .do_load
.l3:
    mov qword [active_enemies], 5
    mov rdi, level_3_name

.do_load:
    mov rax, 2       ; open()
    mov rsi, 0
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .error
    mov r8, rax
    mov rbx, 0

.read_loop:
    cmp rbx, 100
    jge .close
    mov rax, 0       ; read()
    mov rdi, r8
    mov rsi, buffer
    mov rdx, 1
    syscall
    cmp rax, 0
    je .close
    mov al, [buffer]

    cmp al, 10       ; ignora \n
    je .read_loop
    cmp al, 13       ; ignora \r
    je .read_loop

    mov [map + rbx], al
    inc rbx
    jmp .read_loop

.close:
    mov rax, 3       ; close()
    mov rdi, r8
    syscall
    ret

.error:
    ret

; --- Movimento do jogador ---
try_player_move:
    push rcx
    push rdx
    
    mov rcx, 0
.chk_enemy:
    cmp rcx, [active_enemies]
    jge .chk_map

    mov r15, [enemies_hp + rcx*8]
    cmp r15, 0
    jle .next_e

    ; colisão com inimigo?
    cmp rax, [enemies_y + rcx*8]
    jne .next_e
    cmp rbx, [enemies_x + rcx*8]
    jne .next_e

    ; dano no inimigo
    sub r15, 10
    mov [enemies_hp + rcx*8], r15
    cmp r15, 0
    jle .kill_e
    mov rax, 0
    jmp .end

.kill_e:
    push rcx
    call spawn_single_enemy
    pop rcx
    mov r15, [player_hp]
    add r15, 5        ; cura ao matar
    mov [player_hp], r15
    mov rax, 1
    jmp .end

.next_e:
    inc rcx
    jmp .chk_enemy

; checa bloco do mapa
.chk_map:
    mov rcx, rax
    imul rcx, 10
    add rcx, rbx
    lea rdx, [map]
    add rdx, rcx
    movzx r8, byte [rdx]
    
    cmp r8, '#'
    je .blocked
    cmp r8, '+'
    je .pickup
    cmp r8, '>'
    je .next_lvl

    mov rax, 1
    jmp .end

; pegar vida
.pickup:
    mov r15, [player_hp]
    add r15, 20
    mov [player_hp], r15
    mov byte [rdx], '.'
    mov rax, 1
    jmp .end

; mudar de level
.next_lvl:
    mov al, [current_level]
    cmp al, 1
    je .go_l2
    cmp al, 2
    je .go_l3

    ; level final -> vitória
    mov byte [current_level], 4
    mov rax, 1
    jmp .end

.go_l2:
    mov byte [current_level], 2
    jmp .reset_lvl
.go_l3:
    mov byte [current_level], 3

.reset_lvl:
    call load_level
    mov qword [player_x], 1
    mov qword [player_y], 1
    call respawn_all_enemies
    mov rax, 0
    jmp .end

.blocked:
    mov rax, 0

.end:
    pop rdx
    pop rcx
    ret

; --- Checa parede ---
is_wall:
    push rcx
    push rdx
    mov rcx, rax
    imul rcx, 10
    add rcx, rbx
    lea rdx, [map]
    add rdx, rcx
    movzx r8, byte [rdx]
    pop rdx
    pop rcx
    cmp r8, '#'
    je .yes
    mov rax, 0
    ret
.yes:
    mov rax, 1
    ret
