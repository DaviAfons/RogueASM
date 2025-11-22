%include "input.inc"

section .data
    ; variáveis globais
    global player_x, player_y, steps, player_hp, current_level
    global enemies_x, enemies_y, enemies_hp, active_enemies

    current_level db 1

    player_x: dq 1
    player_y: dq 1
    player_hp: dq 100
    steps:    dq 0

    active_enemies: dq 1

    ; até 10 inimigos
    enemies_x:  dq 0,0,0,0,0,0,0,0,0,0
    enemies_y:  dq 0,0,0,0,0,0,0,0,0,0
    enemies_hp: dq 30,30,30,30,30,30,30,30,30,30

section .bss
    global map
    map resb 100

extern key
extern respawn_all_enemies
extern update_all_enemies_ai
extern try_player_move

section .text
global init_game, update_game

; reset inicial
init_game:
    mov qword [steps], 0
    call respawn_all_enemies
    ret

update_game:
    mov al, [key]
    cmp al, 'w'
    je try_up
    cmp al, 's'
    je try_down
    cmp al, 'a'
    je try_left
    cmp al, 'd'
    je try_right
    ret

; --- Movimentos do jogador ---
try_up:
    mov rax, [player_y]
    dec rax
    mov rbx, [player_x]
    call try_player_move
    cmp rax, 1
    je .ok
    ret
.ok:
    dec qword [player_y]
    jmp process_turn

try_down:
    mov rax, [player_y]
    inc rax
    mov rbx, [player_x]
    call try_player_move
    cmp rax, 1
    je .ok
    ret
.ok:
    inc qword [player_y]
    jmp process_turn

try_left:
    mov rax, [player_y]
    mov rbx, [player_x]
    dec rbx
    call try_player_move
    cmp rax, 1
    je .ok
    ret
.ok:
    dec qword [player_x]
    jmp process_turn

try_right:
    mov rax, [player_y]
    mov rbx, [player_x]
    inc rbx
    call try_player_move
    cmp rax, 1
    je .ok
    ret
.ok:
    inc qword [player_x]
    jmp process_turn

; avança turno (passo + IA)
process_turn:
    inc qword [steps]
    call update_all_enemies_ai
    ret
