# isAlphav2.s
# Purpose: A program to check if a user-input character is alphabetic.
# The check is implemented not using logical operations, but rather through comparisons.
#
# Author: Eduardo Carrasco Jr
# Date: 07/18/2025
# Purpose: Reads in user input for a character,
# checks if it is an alphabetic character (A-Z or a-z),
# and prints the result to the console.
# 
# Parameters:
#   R0: The character to be checked.
# Returns:
#   R0: 1 if the character is alphabetic, 0 otherwise.
#   Prints out the results to the console.
#
# Compile and run instructions:
#   Assemble with: as -o isAlphav2.o isAlphav2.s
#   Link with: gcc -o isAlphav2 isAlphav2.o
#   Run with: ./isAlphav2
#
.text
.global main

# Main function
# This function handles user input and output.
# It reads a character, checks if it is alphabetic, and prints the result.
# The character is expected to be entered followed by a newline.
# The function uses system calls to write to stdout and read from stdin.
# It also calls the is_alpha function to perform the alphabetic check.
main:
    mov     r0, #1
    ldr     r1, =prompt_msg
    ldr     r2, =prompt_msg_len
    mov     r7, #4
    svc     #0

    mov     r0, #0
    ldr     r1, =char_buffer
    mov     r2, #2
    mov     r7, #3
    svc     #0

    ldr     r1, =char_buffer
    ldrb    r0, [r1]

    bl      is_alpha

    cmp     r0, #1
    # If the character is alphabetic, branch to print_is_alpha
    # else branch to print_not_alpha

    beq     .L_print_is_alpha
    b       .L_print_not_alpha
# print for "NOT alphabetic"    
.L_print_not_alpha:
    mov     r0, #1
    ldr     r1, =quote_char
    mov     r2, #quote_char_len
    mov     r7, #4
    svc     #0

    mov     r0, #1
    ldr     r1, =char_buffer
    mov     r2, #1
    mov     r7, #4
    svc     #0

    mov     r0, #1
    ldr     r1, =quote_char
    mov     r2, #quote_char_len
    mov     r7, #4
    svc     #0

    mov     r0, #1
    ldr     r1, =not_alpha_msg
    ldr     r2, =not_alpha_msg_len
    mov     r7, #4
    svc     #0
    b       .L_exit
# print for "is alphabetic"
.L_print_is_alpha:
    mov     r0, #1
    ldr     r1, =quote_char
    mov     r2, #quote_char_len
    mov     r7, #4
    svc     #0

    mov     r0, #1
    ldr     r1, =char_buffer
    mov     r2, #1
    mov     r7, #4
    svc     #0

    mov     r0, #1
    ldr     r1, =quote_char
    mov     r2, #quote_char_len
    mov     r7, #4
    svc     #0

    mov     r0, #1
    ldr     r1, =is_alpha_msg
    ldr     r2, =is_alpha_msg_len
    mov     r7, #4
    svc     #0

.L_exit:
    mov     r0, #0
    mov     r7, #1
    svc     #0
# Check if the character is alphabetic and capital letter
is_alpha:
    cmp     r0, #'A'
    blt     .L_check_lowercase
    cmp     r0, #'Z'
    ble     .L_is_alpha_true
# Check if the character is alphabetic and lowercase letter
.L_check_lowercase:
    cmp     r0, #'a'
    blt     .L_is_alpha_false
    cmp     r0, #'z'
    ble     .L_is_alpha_true
# If the character is not in the alphabetic range, return false
.L_is_alpha_false:
    mov     r0, #0
    bx      lr
# If the character is in the alphabetic range, return true
.L_is_alpha_true:
    mov     r0, #1
    bx      lr

# Standard Read in and Write Messages
# These messages are used for user prompts and output.
.data
    prompt_msg:         .ascii "Enter a character: "
    prompt_msg_len = . - prompt_msg

    is_alpha_msg:       .ascii " is an alphabetic character.\n"
    is_alpha_msg_len = . - is_alpha_msg

    not_alpha_msg:      .ascii " is NOT an alphabetic character.\n"
    not_alpha_msg_len = . - not_alpha_msg

    char_buffer:        .space 2

    quote_char:         .ascii ""
    quote_char_len = . - quote_char

.text
# End of isAlphav2.s