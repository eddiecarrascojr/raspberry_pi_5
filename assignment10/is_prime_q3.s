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
#   AssemBLe and Link with: gcc -o is_prime_q3 is_prime_q3.s
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
# Main function 
# This function initializes the random number generation, prompts the user for a maximum number,
# generates a random number within that range, and then enters a loop to allow the user to
main:
    LDR r0, =prompt_max
    BL printf

    SUB sp, sp, #4
    MOV r1, sp
    LDR r0, =format_int
    BL scanf
    LDR r6, [sp]
    ADD sp, sp, #4

    # If user enters 0, re-prompt
    CMP r6, #0
    beq main

    MOV r0, #0
    BL time
    # Seed the random number generator with
    BL srand
    BL rand

    MOV r7, r0          
    MOV r1, r6         
    BL __aeabi_uidiv    
    MUL r0, r0, r6      
    SUB r0, r7, r0      

    ADD r0, r0, #1
    MOV r4, r0
    MOV r5, #0

# Guessing loop
guess_loop:
    LDR r0, =prompt_guess
    BL printf

    SUB sp, sp, #4
    MOV r1, sp
    LDR r0, =format_int
    BL scanf
    LDR r2, [sp]
    ADD sp, sp, #4

    ADD r5, r5, #1

    CMP r2, r4
    BLT too_low
    BGT too_high
    BEQ correct

# if the guess is too low, print a message and loop back
too_low:
    LDR r0, =msg_low
    BL printf
    B guess_loop

# if the guess is too high, print a message and loop back
too_high:
    LDR r0, =msg_high
    BL printf
    B guess_loop

# If the guess is correct print the number of tries
correct:
    LDR r0, =msg_correct
    BL printf
    MOV r1, r5
    LDR r0, =format_int
    BL printf
    LDR r0, =msg_tries
    BL printf

    MOV r7, #1
    SVC #0

# printf and scanf functions for I/O operations of user input and output
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