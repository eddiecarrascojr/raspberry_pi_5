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
# Compile and run inSTRuctions:
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

# print current character of string
print_string:
    STR lr, [sp, #-4]!
    STR r3, [sp, #-4]!

    MOV r3, r0

# Print the string one character at a time
print_loop:
    LDR r0, [r3], #1
    CMP r0, #0
    BEQ print_done

    MOV r0, #1
    SUB r1, r3, #1
    MOV r2, #1
    
    STR r3, [sp, #-4]!
    MOV r7, #4
    SVC #0
    LDR r3, [sp], #4

    B print_loop

# Finish printing the STRing for the loop
print_done:
    LDR r3, [sp], #4
    LDR lr, [sp], #4
    BX lr

# Read input from the user
# r0: pointer to the buffer where input will be stored
read_input:
    STR lr, [sp, #-4]!
    
    MOV r2, r1
    MOV r1, r0
    MOV r0, #0
    MOV r7, #3
    SVC #0

    LDR lr, [sp], #4
    BX lr

# convert a string to an integer
string_to_int:
    STR lr, [sp, #-4]!
    STR r5, [sp, #-4]!
    STR r4, [sp, #-4]!
    MOV r4, r0
    MOV r5, #0

# Convert ASCII to integer
atoi_loop:
    LDR r1, [r4], #1
    CMP r1, #'0'
    BLT atoi_done
    CMP r1, #'9'
    BGT atoi_done
    SUB r1, r1, #'0'
    MOV r2, #10
    MUL r5, r2, r5
    ADD r5, r5, r1
    B atoi_loop

# End of conversion loop
atoi_done:
    MOV r0, r5
    LDR r4, [sp], #4
    LDR r5, [sp], #4
    LDR lr, [sp], #4
    BX lr

# Print an integer to the console
print_int:
    STR lr, [sp, #-4]!
    STR r4, [sp, #-4]!
    STR r3, [sp, #-4]!
    STR r2, [sp, #-4]!
    STR r1, [sp, #-4]!

    LDR r3, =input_buffer
    ADD r3, r3, #23
    MOV r2, #0
    STRB r2, [r3]
    ADD r3, r3, #-1
    MOV r4, r0

    CMP r4, #0
    BNE print_int_loop
    MOV r2, #'0'
    STRB r2, [r3]
    B print_int_done

# Loop to print the integer
print_int_loop:
    MOV r0, r4
    MOV r1, #10
    BL _divide
    MOV r4, r0
    MOV r2, r1
    ADD r2, r2, #'0'
    STRB r2, [r3], #-1
    CMP r4, #0
    BNE print_int_loop

# Finish printing the integer
print_int_done:
    ADD r0, r3, #1
    BL print_STRing
    LDR r1, [sp], #4
    LDR r2, [sp], #4
    LDR r3, [sp], #4
    LDR r4, [sp], #4
    LDR lr, [sp], #4
    BX lr

# Divide r0 by r1, return quotient in r0 and remainder in r1
divide:
    STR lr, [sp, #-4]!
    STR r3, [sp, #-4]!
    STR r2, [sp, #-4]!
    MOV r2, #0

# Divide loop for each integer
divide_loop:
    CMP r0, r1
    BLT divide_done
    SUB r0, r0, r1
    ADD r2, r2, #1
    B divide_loop

# Finish division loop
divide_done:
    MOV r1, r0
    MOV r0, r2
    LDR r2, [sp], #4
    LDR r3, [sp], #4
    LDR lr, [sp], #4
    BX lr

# Main function
main:
    STR lr, [sp, #-4]!

    LDR r0, =prompt_max
    bl print_STRing
    LDR r0, =input_buffer
    MOV r1, #24
    bl read_input
    LDR r0, =input_buffer
    bl string_to_int
    MOV r5, r0
    MOV r4, #1

# Guess loop initialization
guess_loop:
    CMP r4, r5
    bgt _exit
    add r6, r4, r5
    lsr r6, r6, #1
    LDR r0, =prompt_guess
    bl _print_STRing
    MOV r0, r6
    bl print_int
    LDR r0, =prompt_hilo
    bl print_STRing
    LDR r0, =input_buffer
    MOV r1, #4
    bl read_input
    LDR r0, =input_buffer
    LDRB r1, [r0]
    CMP r1, #'c'
    BEQ win
    CMP r1, #'h'
    BEQ guess_higher
    CMP r1, #'l'
    BEQ guess_lower
    LDR r0, =msg_error_input
    bl print_STRing
    B guess_loop

guess_higher:
    add r4, r6, #1
    B guess_loop

guess_lower:
    SUB r5, r6, #1
    B guess_loop

win:
    LDR r0, =msg_win
    bl _print_STRing
    B _exit

exit:
    MOV r0, #0
    LDR lr, [sp], #4
    BX lr

# standard print STRing function for user input and output
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