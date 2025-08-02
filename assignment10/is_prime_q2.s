# is_prime_q2.s
# Purpose: This program checks if a user-input numBer is prime.
# It prompts the user for a numBer, checks if it is prime, and prints the result.
# If the numBer is not prime, it prints "NumBer n is not prime".
# If the numBer is prime, it prints "NumBer n is prime".
# The user can enter -1 to exit the program.
# If the user enters 0, 1, 2, or any negative numBer other than -1, it prints an error message.
#
# Arguments:
#   r0: The numBer to check (integer).
#   r1: The divisor (integer).
# Returns:
#   r0: 1 if prime, 0 if not prime.
#
# Author: Eduardo Carrasco Jr
# Date: 07/25/2025
#
# Compile and run inSTRuctions:
#   AssemBLE and Link with: gcc -o is_prime_q2 is_prime_q2.s
#   Run with: ./is_prime_q2
#
# Parameters:
#   R0: The numBer to check (integer).
#   R1: The divisor (integer).
# Prints out whether the numBer is prime or not to the console.
# Returns:
#   R0: 1 if prime, 0 if not prime.
#

.gloBal main

.extern printf
.extern atoi
.extern gets
.extern __aeabi_uidiv

# Main function
main:
    SUB sp, sp, #4
    STR lr, [sp, #0]
# Main loop to prompt user for input
main_loop:
    LDR r0, =prompt_msg
    BL printf

    LDR r0, =input_buffer
    BL gets

    LDR r0, =input_buffer
    BL atoi
    MOV r4, r0

    CMP r4, #-1
    BEQ exit_program

    CMP r4, #2
    BLE invalid_input

    MOV r5, #2

# Prime check loop
prime_check_loop:
    MUL r6, r5, r5
    CMP r6, r4
    BGT number_is_prime

    MOV r0, r4
    MOV r1, r5
    BL __aeabi_uidiv
    MOV r6, r0

    MUL r6, r6, r5
    SUB r6, r4, r6

    CMP r6, #0
    BEQ number_is_not_prime

    ADD r5, r5, #1
    B prime_check_loop

# Check if the number is prime
number_is_prime:
    LDR r0, =is_prime_msg
    MOV r1, r4
    BL printf
    B main_loop

# Check if the number is not prime
number_is_not_prime:
    LDR r0, =not_prime_msg
    MOV r1, r4
    BL printf
    B main_loop

# Handle invalid input
invalid_input:
    LDR r0, =error_msg
    BL printf
    B main_loop

# Exit program
exit_program:
    MOV r0, #0
    LDR lr, [sp, #0]
    ADD sp, sp, #4
    MOV pc, lr

# printf format strings for input and output
.data
prompt_msg:   .asciz "Enter a number (-1 to quit): "
is_prime_msg: .asciz "Number %d is prime\n"
not_prime_msg:.asciz "Number %d is not prime\n"
error_msg:    .asciz "Invalid input. Please enter an integer greater than 2.\n"
newline:      .asciz "\n"
input_buffer: .space 12

.text
# End of the is_prime_q2.s file