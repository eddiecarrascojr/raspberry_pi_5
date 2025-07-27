# is_prime_q1.s
# Purpose: A function to calculate remainder without using UDIV/SDIV or MOD/REM instructions.
# This function performs remainder by repeated subtraction.
# Arguments:
#   r0: dividend
#   r1: divisor
# Returns:
#   r0: remainder

# Author: Eduardo Carrasco Jr
# Date: 07/25/2025
#
# Compile and run instructions:
#   Assemble and Link with: gcc -o is_prime_q1 is_prime_q1.s
#   Run with: ./is_prime_q1
#
# Parameters:
#   R0: The number to check (integer).
#   R1: The divisor (integer).
# Prints out whether the number is prime or not to the console.
# Returns:
#   R0: 1 if prime, 0 if not prime.
#

.data
    prompt_msg: .asciz "Enter a number (n > 2): "
    result_msg: .asciz "Prime numbers up to n are: "
    comma_space: .asciz ", "
    newline: .asciz "\n"
    scan_format: .asciz "%d"
    print_format: .asciz "%d"

.text
.global main

get_remainder:
    str lr, [sp, #-4]!

remainder_loop:
    cmp r0, r1
    blt remainder_done
    sub r0, r0, r1
    b remainder_loop

remainder_done:
    ldr pc, [sp], #4

main:
    push {fp, lr}
    add fp, sp, #4

    ldr r0, =prompt_msg
    bl printf

    sub sp, sp, #4
    mov r1, sp
    ldr r0, =scan_format
    bl scanf
    ldr r4, [sp]
    add sp, sp, #4

    ldr r0, =result_msg
    bl printf

    mov r5, #3

outer_loop_start:
    cmp r5, r4
    bgt outer_loop_end

    mov r8, #1
    mov r6, #2

    mov r0, r5
    lsr r7, r0, #1

inner_loop_start:
    cmp r6, r7
    bgt is_prime_check

    mov r0, r5
    mov r1, r6
    bl get_remainder

    cmp r0, #0
    beq not_prime

    add r6, r6, #1
    b inner_loop_start

not_prime:
    mov r8, #0
    b is_prime_check

is_prime_check:
    cmp r8, #1
    bne outer_loop_continue

    mov r1, r5
    ldr r0, =print_format
    bl printf

    ldr r0, =comma_space
    bl printf

outer_loop_continue:
    add r5, r5, #2
    b outer_loop_start

outer_loop_end:
    ldr r0, =newline
    bl printf

    mov r0, #0
    sub sp, fp, #4
    pop {fp, pc}

# End of the main program