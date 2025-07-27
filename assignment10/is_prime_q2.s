# is_prime_q2.s
# Purpose: This program checks if a user-input number is prime.
# It prompts the user for a number, checks if it is prime, and prints the result.
# If the number is not prime, it prints "Number n is not prime".
# If the number is prime, it prints "Number n is prime".
# The user can enter -1 to exit the program.
# If the user enters 0, 1, 2, or any negative number other than -1, it prints an error message.
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
#   Assemble and Link with: gcc -o is_prime_q2 is_prime_q2.s
#   Run with: ./is_prime_q2
#
# Parameters:
#   R0: The number to check (integer).
#   R1: The divisor (integer).
# Prints out whether the number is prime or not to the console.
# Returns:
#   R0: 1 if prime, 0 if not prime.
#

.global main

.extern printf
.extern atoi
.extern gets
.extern __aeabi_uidiv

main:
    sub sp, sp, #4
    str lr, [sp, #0]

main_loop:
    ldr r0, =prompt_msg
    bl printf

    ldr r0, =input_buffer
    bl gets

    ldr r0, =input_buffer
    bl atoi
    mov r4, r0

    cmp r4, #-1
    beq exit_program

    cmp r4, #2
    ble invalid_input

    mov r5, #2

prime_check_loop:
    mul r6, r5, r5
    cmp r6, r4
    bgt number_is_prime

    mov r0, r4
    mov r1, r5
    bl __aeabi_uidiv
    mov r6, r0

    mul r6, r6, r5
    sub r6, r4, r6

    cmp r6, #0
    beq number_is_not_prime

    add r5, r5, #1
    b prime_check_loop

number_is_prime:
    ldr r0, =is_prime_msg
    mov r1, r4
    bl printf
    b main_loop

number_is_not_prime:
    ldr r0, =not_prime_msg
    mov r1, r4
    bl printf
    b main_loop

invalid_input:
    ldr r0, =error_msg
    bl printf
    b main_loop

exit_program:
    mov r0, #0
    ldr lr, [sp, #0]
    add sp, sp, #4
    mov pc, lr

.data
prompt_msg:   .asciz "Enter a number (-1 to quit): "
is_prime_msg: .asciz "Number %d is prime\n"
not_prime_msg:.asciz "Number %d is not prime\n"
error_msg:    .asciz "Invalid input. Please enter an integer greater than 2.\n"
newline:      .asciz "\n"
input_buffer: .space 12

.text
# End of the is_prime_q2.s file