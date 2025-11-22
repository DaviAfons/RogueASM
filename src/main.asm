%include "display.inc"
%include "engine.inc"
%include "input.inc"

section .data
msg_exit db "Game Over...", 10
msg_exit_len equ $ - msg_exit

section .text
global _start

_start:
    call draw_title_screen
    call read_input
    call load_level
    call init_game

.loop:
    ; vitória quando level = 4
    extern current_level
    mov al, [current_level]
    cmp al, 4
    je .victory

    call draw_map
    call read_input
    call update_game

    ; morte do jogador
    extern player_hp
    mov rax, [player_hp]
    cmp rax, 0
    jle .game_over

    jmp .loop

.victory:
    call draw_win_screen
    call read_input
    jmp .exit

.game_over:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_exit
    mov rdx, msg_exit_len
    syscall

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall
