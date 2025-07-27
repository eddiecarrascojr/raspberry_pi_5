# is_prime_q4.s
# This program ask the user for a maximum number and then generates a random number
# between 1 and that maximum. The user then guesses the number, and the program
# checks if the guess is correct, too high, or too low.
#
# Arguments:
#   r0: The number to check (integer).
#   r1: The divisor (integer).
# Returns:
#   r0: 1 if prime, 0 if not prime.
#
# Author: Eduardo Carrasco Jr
# Date: 07/25/2025
#
# Compile and run instructions:
#   Assemble and Link with: gcc -o is_prime_q3 is_prime_q3.s
#   Run with: ./is_prime_q3
#
# Parameters:
#   R0: The number to check (integer).
#   R1: The divisor (integer).
# Prints out whether the number is prime or not to the console.
# Returns:
#   R0: 1 if prime, 0 if not prime.
#


.global main

_print_string:
    str lr, [sp, #-4]!
    str r3, [sp, #-4]!

    mov r3, r0
_print_loop:
    ldrb r0, [r3], #1
    cmp r0, #0
    beq _print_done

    mov r0, #1
    sub r1, r3, #1
    mov r2, #1
    
    str r3, [sp, #-4]!
    mov r7, #4
    svc #0
    ldr r3, [sp], #4

    b _print_loop

_print_done:
    ldr r3, [sp], #4
    ldr lr, [sp], #4
    bx lr

_read_input:
    str lr, [sp, #-4]!
    
    mov r2, r1
    mov r1, r0
    mov r0, #0
    mov r7, #3
    svc #0

    ldr lr, [sp], #4
    bx lr

_string_to_int:
    str lr, [sp, #-4]!
    str r5, [sp, #-4]!
    str r4, [sp, #-4]!
    mov r4, r0
    mov r5, #0
_atoi_loop:
    ldrb r1, [r4], #1
    cmp r1, #'0'
    blt _atoi_done
    cmp r1, #'9'
    bgt _atoi_done
    sub r1, r1, #'0'
    mov r2, #10
    mul r5, r2, r5
    add r5, r5, r1
    b _atoi_loop
_atoi_done:
    mov r0, r5
    ldr r4, [sp], #4
    ldr r5, [sp], #4
    ldr lr, [sp], #4
    bx lr

_print_int:
    str lr, [sp, #-4]!
    str r4, [sp, #-4]!
    str r3, [sp, #-4]!
    str r2, [sp, #-4]!
    str r1, [sp, #-4]!

    ldr r3, =input_buffer
    add r3, r3, #23
    mov r2, #0
    strb r2, [r3]
    add r3, r3, #-1
    mov r4, r0

    cmp r4, #0
    bne _print_int_loop
    mov r2, #'0'
    strb r2, [r3]
    b _print_int_done

_print_int_loop:
    mov r0, r4
    mov r1, #10
    bl _divide
    mov r4, r0
    mov r2, r1
    add r2, r2, #'0'
    strb r2, [r3], #-1
    cmp r4, #0
    bne _print_int_loop

_print_int_done:
    add r0, r3, #1
    bl _print_string
    ldr r1, [sp], #4
    ldr r2, [sp], #4
    ldr r3, [sp], #4
    ldr r4, [sp], #4
    ldr lr, [sp], #4
    bx lr

_divide:
    str lr, [sp, #-4]!
    str r3, [sp, #-4]!
    str r2, [sp, #-4]!
    mov r2, #0
_divide_loop:
    cmp r0, r1
    blt _divide_done
    sub r0, r0, r1
    add r2, r2, #1
    b _divide_loop
_divide_done:
    mov r1, r0
    mov r0, r2
    ldr r2, [sp], #4
    ldr r3, [sp], #4
    ldr lr, [sp], #4
    bx lr

main:
    str lr, [sp, #-4]!

    ldr r0, =prompt_max
    bl _print_string
    ldr r0, =input_buffer
    mov r1, #24
    bl _read_input
    ldr r0, =input_buffer
    bl _string_to_int
    mov r5, r0
    mov r4, #1

guess_loop:
    cmp r4, r5
    bgt _exit
    add r6, r4, r5
    lsr r6, r6, #1
    ldr r0, =prompt_guess
    bl _print_string
    mov r0, r6
    bl _print_int
    ldr r0, =prompt_hilo
    bl _print_string
    ldr r0, =input_buffer
    mov r1, #4
    bl _read_input
    ldr r0, =input_buffer
    ldrb r1, [r0]
    cmp r1, #'c'
    beq win
    cmp r1, #'h'
    beq guess_higher
    cmp r1, #'l'
    beq guess_lower
    ldr r0, =msg_error_input
    bl _print_string
    b guess_loop

guess_higher:
    add r4, r6, #1
    b guess_loop

guess_lower:
    sub r5, r6, #1
    b guess_loop

win:
    ldr r0, =msg_win
    bl _print_string
    b _exit

_exit:
    mov r0, #0
    ldr lr, [sp], #4
    bx lr

.data
prompt_max:      .asciz "Enter the maximum number in the range (e.g., 100): "
prompt_guess:    .asciz "\nMy guess is "
prompt_hilo:     .asciz ". Is your secret number (h)igher, (l)ower, or (c)orrect? "
msg_win:         .asciz "\nGreat! I guessed your number.\n"
msg_error_input: .asciz "\nInvalid input. Please enter 'h', 'l', or 'c'.\n"
newline:         .asciz "\n"

.bss
.lcomm input_buffer, 24

.text
# End of the is_prime_q4.s file