# is_prime_q3.s
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

main:
    ldr r0, =prompt_max
    bl printf

    sub sp, sp, #4
    mov r1, sp
    ldr r0, =format_int
    bl scanf
    ldr r6, [sp]
    add sp, sp, #4

    # If user enters 0, re-prompt
    cmp r6, #0
    beq main

    mov r0, #0
    bl time
    bl srand
    bl rand

    # Corrected Modulo Calculation 
    # Save random number in a safe register (r7)
    # Move max_value into r1 for division
    # r0 = quotient. r0-r3 are now clobbered.
    # r0 = quotient * max_value (use safe r6)
    # r0 = original_random (from r7) - (quotient * max_value)
    mov r7, r0          
    mov r1, r6         
    bl __aeabi_uidiv    
    mul r0, r0, r6      
    sub r0, r7, r0      

    add r0, r0, #1
    mov r4, r0
    mov r5, #0

guess_loop:
    ldr r0, =prompt_guess
    bl printf

    sub sp, sp, #4
    mov r1, sp
    ldr r0, =format_int
    bl scanf
    ldr r2, [sp]
    add sp, sp, #4

    add r5, r5, #1

    cmp r2, r4
    blt too_low
    bgt too_high
    beq correct

too_low:
    ldr r0, =msg_low
    bl printf
    b guess_loop

too_high:
    ldr r0, =msg_high
    bl printf
    b guess_loop

correct:
    ldr r0, =msg_correct
    bl printf
    mov r1, r5
    ldr r0, =format_int
    bl printf
    ldr r0, =msg_tries
    bl printf

    mov r7, #1
    svc #0

.data
    prompt_max: .asciz "Enter the maximum number for the guessing game (must be > 0): "
    prompt_guess: .asciz "Enter your guess: "
    msg_low: .asciz "Too low!\n"
    msg_high: .asciz "Too high!\n"
    msg_correct: .asciz "Correct! You guessed the number in "
    msg_tries: .asciz " tries.\n"
    format_int: .asciz "%d"

.text
# End of the is_prime_q3.s file