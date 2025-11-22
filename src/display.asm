%include "engine.inc"

section .data
    player_icon db '@'
    enemy_icon  db 'E'
    newline     db 10
    heart_icon  db '*' 
    enemy_hp_icon db 'x'
    exit_icon   db '>'
    fog_icon    db ' '
    
    ; --- CORES ---
    color_red     db 27, '[31m'
    len_red       equ $ - color_red
    color_green   db 27, '[32m'
    len_green     equ $ - color_green
    color_yellow  db 27, '[33m'
    len_yellow    equ $ - color_yellow
    color_blue    db 27, '[34m'
    len_blue      equ $ - color_blue
    color_magenta db 27, '[35m'
    len_magenta   equ $ - color_magenta
    color_cyan    db 27, '[36m'
    len_cyan      equ $ - color_cyan
    color_reset   db 27, '[0m'
    len_reset     equ $ - color_reset
    color_white   db 27, '[37m'
    len_white     equ $ - color_white
    color_grey    db 27, '[90m'
    len_grey      equ $ - color_grey

    clear_screen db 27, '[H', 27, '[2J'
    clear_len equ $ - clear_screen

    hud_hp db "HP: "
    hud_hp_len equ $ - hud_hp
    hud_enemy db " | Boss: "
    hud_enemy_len equ $ - hud_enemy
    
    msg_win db 10, 10, "   PARABENS! VOCE VENCEU O DESAFIO!   ", 10, 10
    msg_win_len equ $ - msg_win

    ; --- TELA DE TÍTULO ---
    title_line1 db 10, "  ____                        _  ", 10
    len_t1 equ $ - title_line1
    title_line2 db " |  _ \ ___   __ _ _   _  ___| | ", 10
    len_t2 equ $ - title_line2
    title_line3 db " | |_) / _ \ / _` | | | |/ _ \ | ", 10
    len_t3 equ $ - title_line3
    title_line4 db " |  _ < (_) | (_| | |_| |  __/_| ", 10
    len_t4 equ $ - title_line4
    title_line5 db " |_| \_\___/ \__, |\__,_|\___(_) ", 10
    len_t5 equ $ - title_line5
    title_line6 db "             |___/               ", 10, 10
    len_t6 equ $ - title_line6
    
    msg_start db "      PRESSIONE [ENTER] PARA JOGAR", 10
    len_start equ $ - msg_start

section .text
global draw_map, draw_win_screen, draw_title_screen

; --- TELA DE TÍTULO ---
draw_title_screen:
    ; Limpa tela
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, clear_len
    syscall
    
    ; Define cor Amarela para o logo
    mov rax, 1
    mov rdi, 1
    mov rsi, color_yellow
    mov rdx, len_yellow
    syscall
    
    ; Imprime Logo Linha por Linha
    mov rax, 1
    mov rdi, 1
    mov rsi, title_line1
    mov rdx, len_t1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, title_line2
    mov rdx, len_t2
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, title_line3
    mov rdx, len_t3
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, title_line4
    mov rdx, len_t4
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, title_line5
    mov rdx, len_t5
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, title_line6
    mov rdx, len_t6
    syscall

    ; Define cor Ciano para o texto de Start
    mov rax, 1
    mov rdi, 1
    mov rsi, color_cyan
    mov rdx, len_cyan
    syscall

    ; Imprime msg start
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_start
    mov rdx, len_start
    syscall
    
    ; Reset de cor
    mov rax, 1
    mov rdi, 1
    mov rsi, color_reset
    mov rdx, len_reset
    syscall
    ret

; --- TELA DE VITÓRIA ---
draw_win_screen:
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, clear_len
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, color_green
    mov rdx, len_green
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_win
    mov rdx, msg_win_len
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, color_reset
    mov rdx, len_reset
    syscall
    ret

; --- DESENHA MAPA (GAMEPLAY) ---
draw_map:
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, clear_len
    syscall

    mov r8, 0
.row_loop:
    cmp r8, 10
    jge .draw_hud

    mov r9, 0
.col_loop:
    cmp r9, 10
    jge .print_newline

    ; FOG OF WAR
    mov rax, [player_x]
    sub rax, r9
    imul rax, rax
    mov rbx, [player_y]
    sub rbx, r8
    imul rbx, rbx
    add rax, rbx
    cmp rax, 12
    jg .draw_fog

    ; Player
    cmp r8, [player_y]
    jne .check_enemies_draw
    cmp r9, [player_x]
    jne .check_enemies_draw
    mov r10, color_yellow
    mov r11, len_yellow
    mov rsi, player_icon
    jmp .print_colored

.check_enemies_draw:
    mov rcx, 0
.enemy_loop:
    cmp rcx, [active_enemies]
    jge .check_terrain
    
    mov rax, [enemies_hp + rcx*8]
    cmp rax, 0
    jle .next_enemy_chk

    mov rax, [enemies_y + rcx*8]
    cmp rax, r8
    jne .next_enemy_chk
    mov rax, [enemies_x + rcx*8]
    cmp rax, r9
    jne .next_enemy_chk
    
    mov r10, color_red
    mov r11, len_red
    mov rsi, enemy_icon
    jmp .print_colored

.next_enemy_chk:
    inc rcx
    jmp .enemy_loop

.check_terrain:
    mov rbx, map
    mov rax, r8
    imul rax, 10
    add rax, r9
    add rbx, rax
    
    mov dl, [rbx]
    
    cmp dl, '#'
    je .set_wall
    cmp dl, '+'
    je .set_heal
    cmp dl, '>'
    je .set_exit
    
    mov r10, color_white
    mov r11, len_white
    mov rsi, rbx
    jmp .print_colored

.set_wall:
    mov r10, color_blue
    mov r11, len_blue
    mov rsi, rbx
    jmp .print_colored
.set_heal:
    mov r10, color_green
    mov r11, len_green
    mov rsi, rbx
    jmp .print_colored
.set_exit:
    mov r10, color_magenta
    mov r11, len_magenta
    mov rsi, rbx
    jmp .print_colored

.draw_fog:
    mov r10, color_grey
    mov r11, len_grey
    mov rsi, fog_icon
    jmp .print_colored

.print_colored:
    push rsi
    mov rax, 1
    mov rdi, 1
    mov rsi, r10
    mov rdx, r11
    syscall
    pop rsi
    push rsi
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, color_reset
    mov rdx, len_reset
    syscall
    pop rsi
    inc r9
    jmp .col_loop

.print_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    inc r8
    jmp .row_loop

.draw_hud:
    mov rax, 1
    mov rdi, 1
    mov rsi, hud_hp
    mov rdx, hud_hp_len
    syscall

    mov rcx, [player_hp]
    cmp rcx, 0
    jle .enemy_hud
    
    mov rax, rcx
    mov rbx, 10
    xor rdx, rdx
    idiv rbx
    mov rcx, rax
    cmp rcx, 0
    je .enemy_hud

.hp_loop:
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, color_red
    mov rdx, len_red
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, heart_icon
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, color_reset
    mov rdx, len_reset
    syscall
    pop rcx
    loop .hp_loop

.enemy_hud:
    mov rax, 1
    mov rdi, 1
    mov rsi, hud_enemy
    mov rdx, hud_enemy_len
    syscall

    mov r12, 0 
    mov r13, 0 
.sum_loop:
    cmp r12, [active_enemies]
    jge .print_enemy_bars
    add r13, [enemies_hp + r12*8]
    inc r12
    jmp .sum_loop

.print_enemy_bars:
    cmp r13, 0
    jle .hud_end

    mov rax, r13
    mov rbx, 10
    xor rdx, rdx
    idiv rbx
    mov rcx, rax
    cmp rcx, 0
    je .hud_end

.enemy_hp_loop:
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, color_red
    mov rdx, len_red
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, enemy_hp_icon
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, color_reset
    mov rdx, len_reset
    syscall
    pop rcx
    loop .enemy_hp_loop

.hud_end:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret