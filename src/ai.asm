section .text
    global respawn_all_enemies, spawn_single_enemy, update_all_enemies_ai, random_num_1_8

    ; --- Variáveis do motor ---
    extern active_enemies, enemies_hp, enemies_x, enemies_y
    extern player_x, player_y, player_hp
    
    ; --- Funções externas ---
    extern is_wall

; Respawna todos os inimigos
respawn_all_enemies:
    mov rcx, 0
.loop:
    cmp rcx, [active_enemies]
    jge .end
    mov qword [enemies_hp + rcx*8], 30
    push rcx
    call spawn_single_enemy
    pop rcx
    inc rcx
    jmp .loop
.end:
    ret

; Spawn de um inimigo numa posição válida
spawn_single_enemy:
    mov r12, rcx
.retry:
    call random_num_1_8
    mov [enemies_x + r12*8], rax
    call random_num_1_8
    mov [enemies_y + r12*8], rax

    ; evita spawn no player
    mov rax, [enemies_x + r12*8]
    cmp rax, [player_x]
    jne .chk_wall
    mov rax, [enemies_y + r12*8]
    cmp rax, [player_y]
    je .retry

.chk_wall:
    mov rax, [enemies_y + r12*8]
    mov rbx, [enemies_x + r12*8]

    ; evita spawn dentro de parede
    call is_wall
    cmp rax, 1
    je .retry
    ret

; Retorna número entre 1 e 8
random_num_1_8:
    rdtsc
    xor rdx, rdx
    mov rcx, 8
    div rcx
    mov rax, rdx
    inc rax
    ret

; Atualiza IA de todos
update_all_enemies_ai:
    mov r12, 0
.loop:
    cmp r12, [active_enemies]
    jge .check_hits
    mov rax, [enemies_hp + r12*8]
    cmp rax, 0
    jle .next
    call run_ai
.next:
    inc r12
    jmp .loop
.check_hits:
    call check_all_hits
    ret

; IA básica (persegue ou se move aleatório)
run_ai:
    push r12
    rdtsc
    and al, 0x03
    cmp al, 0
    je .rand

    rdtsc
    test al, 1
    jz .try_x
    jmp .try_y

.try_x:
    call ai_chase_x
    cmp rax, 1
    je .done
    call ai_chase_y
    jmp .done

.try_y:
    call ai_chase_y
    cmp rax, 1
    je .done
    call ai_chase_x
    jmp .done

; Movimentos aleatórios
.rand:
    rdtsc
    and al, 0x03
    cmp al, 0
    je .r_u
    cmp al, 1
    je .r_d
    cmp al, 2
    je .r_l
    jmp .r_r

.r_u: call ai_move_up     ; sobe
      jmp .done
.r_d: call ai_move_down   ; desce
      jmp .done
.r_l: call ai_move_left   ; esquerda
      jmp .done
.r_r: call ai_move_right  ; direita
      jmp .done

.done:
    pop r12
    ret

; Tentam chegar no player
ai_chase_x:
    mov rax, [player_x]
    cmp rax, [enemies_x + r12*8]
    jg ai_move_right
    jl ai_move_left
    mov rax, 0
    ret

ai_chase_y:
    mov rax, [player_y]
    cmp rax, [enemies_y + r12*8]
    jg ai_move_down
    jl ai_move_up
    mov rax, 0
    ret

; Movimentos com checagem de parede
ai_move_up:
    mov rax, [enemies_y + r12*8]
    dec rax
    mov rbx, [enemies_x + r12*8]
    call is_wall
    cmp rax, 1
    je .fail
    dec qword [enemies_y + r12*8]
    mov rax, 1
    ret
.fail: mov rax, 0
       ret

ai_move_down:
    mov rax, [enemies_y + r12*8]
    inc rax
    mov rbx, [enemies_x + r12*8]
    call is_wall
    cmp rax, 1
    je .fail
    inc qword [enemies_y + r12*8]
    mov rax, 1
    ret
.fail: mov rax, 0
       ret

ai_move_left:
    mov rax, [enemies_y + r12*8]
    mov rbx, [enemies_x + r12*8]
    dec rbx
    call is_wall
    cmp rax, 1
    je .fail
    dec qword [enemies_x + r12*8]
    mov rax, 1
    ret
.fail: mov rax, 0
       ret

ai_move_right:
    mov rax, [enemies_y + r12*8]
    mov rbx, [enemies_x + r12*8]
    inc rbx
    call is_wall
    cmp rax, 1
    je .fail
    inc qword [enemies_x + r12*8]
    mov rax, 1
    ret
.fail: mov rax, 0
       ret

; Verifica se inimigo tocou no player
check_all_hits:
    mov rcx, 0
.loop:
    cmp rcx, [active_enemies]
    jge .end
    mov rax, [enemies_hp + rcx*8]
    cmp rax, 0
    jle .next

    mov rax, [enemies_x + rcx*8]
    cmp rax, [player_x]
    jne .next
    mov rax, [enemies_y + rcx*8]
    cmp rax, [player_y]
    jne .next

    ; dano no player
    mov rax, [player_hp]
    sub rax, 15
    mov [player_hp], rax

.next:
    inc rcx
    jmp .loop
.end:
    ret
